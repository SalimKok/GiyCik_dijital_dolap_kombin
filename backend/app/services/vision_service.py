import json
import io
from PIL import Image

try:
    from rembg import remove
except ImportError:
    # Fallback to prevent crash if rembg is not fully installed yet in some environments
    def remove(data): return data

from google import genai
from app.config import settings

# Configure Gemini Client
client = None
if settings.GEMINI_API_KEY:
    client = genai.Client(api_key=settings.GEMINI_API_KEY)

def remove_background(image_bytes: bytes) -> bytes:
    """Removes the background from an image using rembg."""
    try:
        output = remove(image_bytes)
        return output
    except Exception as e:
        print(f"Background removal failed: {e}")
        return image_bytes

def analyze_clothing(image_bytes: bytes) -> dict:
    """Analyzes clothing image using Google Gemini API."""
    if not settings.GEMINI_API_KEY:
        print("GEMINI_API_KEY is missing. Returning default fallback analysis.")
        return {"category": "Üst", "color": "Bilinmiyor", "season": "Mevsimlik", "name": "Kıyafet"}
        
    try:
        # Convert bytes to PIL Image for Gemini
        img = Image.open(io.BytesIO(image_bytes))
        
        # Initialize Gemini model call
        prompt = '''
        Bu resmi analiz et ve giysi hakkında şu bilgileri JSON formatında döndür:
        1. "name": Kıyafet için kısa ve jenerik bir ad (örn: Mavi Kışlık Kazak, Siyah Kot)
        2. "category": Şunlardan biri olmalı: ["Üst", "Alt", "Dış giyim", "Ayakkabı", "Aksesuar", "Şal/Eşarp"]
        3. "color": Baskın rengin Türkçe adı (Örn: Siyah, Beyaz, Kırmızı vb.)
        4. "season": Şunlardan biri olmalı: ["Yazlık", "Kışlık", "Mevsimlik"]
        Sadece JSON objesini döndür, etrafında markdown (```json) veya ters tırnak olmasın.
        '''
        
        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=[prompt, img]
        )
        
        # Parse JSON
        result_text = response.text.replace('```json', '').replace('```', '').strip()
        data = json.loads(result_text)
        return data
    except Exception as e:
        print(f"AI Analysis failed: {e}")
        return {"category": "Üst", "color": "Bilinmiyor", "season": "Mevsimlik", "name": "Kıyafet"}

def generate_outfit(wardrobe_items: list, season: str, weather: str, event: str, style: str, is_hijab: bool = False) -> dict:
    """Generates an outfit from given wardrobe items based on conditions using Gemini."""
    if not settings.GEMINI_API_KEY:
        print("GEMINI_API_KEY is missing. Cannot generate outfit.")
        return {}

    try:
        # Prepare wardrobe data string
        items_str = ""
        for item in wardrobe_items:
            # item dict should have at least id, name, category, color
            items_str += f"- ID: {item.get('id')}, Adı: {item.get('name')}, Kategori: {item.get('category')}, Renk: {item.get('color')}\n"

        prompt = f'''
        Aşağıda kullanıcının gardırobunda bulunan kıyafetlerin listesi var:
        {items_str}

        Kullanıcı şu şartlara uygun bir kombin önerisi istiyor:
        Mevsim: {season}
        Hava: {weather}
        Etkinlik: {event}
        Tarz: {style}
        {'Bu bir tesettür kombinidir. Listeden mutlaka uygun bir "Şal/Eşarp" seç ve "shawl_id" alanını doldur.' if is_hijab else ''}

        Lütfen listedeki kıyafetleri kullanarak uyumlu bir kombin öner.
        Döneceğin cevap SADECE aşağıdaki JSON formatında olmalı, etrafında markdown (```json) veya ekstra metin olmamalı.
        Eğer bir kategori için listede uygun eşya yoksa veya o kategori (örn. aksesuar, dış giyim) opsiyonelse boş string ("") veya o kategorinin keysini null ver.
        
        İstenen JSON formatı:
        {{
            "title": "{style} Tarzı {event} Kombini",
            "description": "Kombinin neden seçildiği, renk uyumları vs. hakkında havalı bir cümle.",
            "top_id": "Üst giyimin ID'si",
            "bottom_id": "Alt giyimin ID'si",
            "shoes_id": "Ayakkabının ID'si",
            "outerwear_id": "Dış giyimin ID'si (varsa, yoksa null)",
            "accessory_id": "Aksesuarın ID'si (varsa, yoksa null)",
            "shawl_id": "Şal/Eşarp'ın ID'si (varsa, yoksa null)"
        }}
        '''

        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt
        )
        text = response.text
        # Remove markdown formatting if any
        result_text = text.replace('```json', '').replace('```', '').strip()
            
        data = json.loads(result_text)
        return data
    except Exception as e:
        import traceback
        traceback.print_exc()
        return {"error": f"AI Hatası: {str(e)} -> Gelen Metin: {response.text if 'response' in locals() else 'Yok'}"}

def generate_travel_pack(wardrobe_items: list, destination: str, start_date: str, end_date: str, purpose: str, is_hijab: bool = False) -> dict:
    """Generates a travel packing list and daily outfits based on destination and purpose."""
    if not settings.GEMINI_API_KEY:
        print("GEMINI_API_KEY is missing. Cannot generate travel pack.")
        return {}

    try:
        items_str = ""
        for item in wardrobe_items:
            items_str += f"- ID: {item.get('id')}, Adı: {item.get('name')}, Kategori: {item.get('category')}, Renk: {item.get('color')}\n"

        prompt = f'''
        Sen profesyonel bir seyahat ve moda asistanısın. Kullanıcı yaklaşan bir seyahati için senden valiz hazırlamanı istiyor.
        Seyahat Detayları:
        - Gidilecek Şehir/Yer: {destination}
        - Başlangıç Tarihi: {start_date}
        - Bitiş Tarihi: {end_date}
        - Seyahat Amacı: {purpose}
        - Tesettür Giyim Tercihi: {'Evet, tesettür kombinleri oluştur (Şal/Eşarp dahil)' if is_hijab else 'Hayır'}
        
        Kullanıcının Dolabındaki Eşyalar:
        {items_str}

        Lütfen belirtilen tarihlerdeki mevsimi ve şehrin iklimini tahmin ederek, kullanıcının dolabından en uygun eşyaları seçip gün gün bir seyahat kombin planı ve genel bir valiz listesi oluştur.
        
        Döneceğin cevap SADECE aşağıdaki JSON formatında olmalı, ekstra metin olmasın:
        {{
            "summary": "Seyahat için valiz seçimi ve şehrin hava durumu hakkında kısa bir tavsiye yazısı",
            "packing_list": ["Önerilen valiz içi genel eşyalar (örn: pasaport, güneş kremi)"],
            "days": [
                {{
                    "day": 1,
                    "title": "İlk gün şehir turu kombini",
                    "top_id": "ID veya null",
                    "bottom_id": "ID veya null",
                    "shoes_id": "ID veya null",
                    "outerwear_id": "ID veya null",
                    "accessory_id": "ID veya null",
                    "shawl_id": "ID veya null"
                }}
            ]
        }}
        Seyahatin gün sayısını Başlangıç ve Bitiş tarihlerinden hesapla (maksimum 7 gün için plan yap). Eğer kıyafet yoksa ilgili ID yerine null dön.
        '''

        response = client.models.generate_content(
            model='gemini-2.5-flash',
            contents=prompt
        )
        text = response.text
        result_text = text.replace('```json', '').replace('```', '').strip()
            
        data = json.loads(result_text)
        return data
    except Exception as e:
        import traceback
        traceback.print_exc()
        return {"error": f"AI Hatası: {str(e)}"}
