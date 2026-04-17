import os
from PIL import Image, ImageDraw, ImageFont

INPUT_IMAGE = r"C:\Users\nanos\Cowork\김태성 선거자료\김태성 브랜딩 팝업.png"
OUTPUT_DIR = r"M:\MyProject777\kimtaesung_sinanjuso\popups"

if not os.path.exists(OUTPUT_DIR):
    os.makedirs(OUTPUT_DIR)


def find_font(size):
    candidates = [
        "C:/Windows/Fonts/malgunbd.ttf",   # Malgun Gothic Bold (Windows)
        "C:/Windows/Fonts/malgun.ttf",      # Malgun Gothic
        "C:/Windows/Fonts/gulim.ttc",
        "C:/Windows/Fonts/batang.ttc",
        "/usr/share/fonts/truetype/nanum/NanumGothicBold.ttf",
        "NanumGothicBold.ttf",
    ]
    for path in candidates:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    return ImageFont.load_default()


def draw_wrapped_text(draw, text, font, x, y, max_width, fill, line_height):
    """Draw text, wrapping at max_width. Returns final y position."""
    words = text
    draw.text((x, y), words, font=font, fill=fill)
    return y + line_height


def generate_popup(index, title_text, subtitle_text, body_lines):
    if not os.path.exists(INPUT_IMAGE):
        print(f"Error: '{INPUT_IMAGE}' not found.")
        return

    base_img = Image.open(INPUT_IMAGE).convert("RGB")

    canvas_w, canvas_h = 1080, 1000
    popup = Image.new("RGB", (canvas_w, canvas_h), (255, 255, 255))
    draw = ImageDraw.Draw(popup)

    # ── Top navy bar ──────────────────────────────────────────────
    BAR_H = 175
    NAV_COLOR = (26, 58, 95)
    ACC_COLOR = (230, 126, 10)
    draw.rectangle([0, 0, canvas_w, BAR_H], fill=NAV_COLOR)

    # Candidate label in bar
    h_font = find_font(50)
    draw.text((canvas_w // 2, BAR_H // 2), "신안군수 예비후보  김태성",
              font=h_font, fill=(255, 255, 255), anchor="mm")

    # ── Candidate photo (left side) ───────────────────────────────
    PHOTO_W, PHOTO_H = 420, 530
    PHOTO_X, PHOTO_Y = 40, BAR_H + 30
    photo = base_img.resize((PHOTO_W, PHOTO_H), Image.LANCZOS)
    popup.paste(photo, (PHOTO_X, PHOTO_Y))

    # ── Right text panel ──────────────────────────────────────────
    TEXT_X = 500
    TEXT_W = canvas_w - TEXT_X - 30

    # Thin accent line under bar on right side
    draw.rectangle([TEXT_X, BAR_H + 12, canvas_w - 30, BAR_H + 17], fill=ACC_COLOR)

    # Title
    t_font = find_font(62)
    ty = BAR_H + 50
    draw.text((TEXT_X, ty), title_text, font=t_font, fill=NAV_COLOR)

    # Subtitle
    s_font = find_font(46)
    sy = ty + 95
    draw.text((TEXT_X, sy), subtitle_text, font=s_font, fill=ACC_COLOR)

    # Divider
    dy = sy + 70
    draw.rectangle([TEXT_X, dy, canvas_w - 30, dy + 3], fill=(200, 200, 200))

    # Body bullet lines
    b_font = find_font(40)
    by = dy + 30
    LINE_GAP = 100
    for line in body_lines:
        draw.text((TEXT_X, by), line, font=b_font, fill=(45, 45, 45))
        by += LINE_GAP

    # ── Bottom accent strip ───────────────────────────────────────
    draw.rectangle([0, canvas_h - 18, canvas_w, canvas_h], fill=NAV_COLOR)

    # ── Save ──────────────────────────────────────────────────────
    file_name = f"KimTaeSung_Popup_NoBtn_{index}.png"
    save_path = os.path.join(OUTPUT_DIR, file_name)
    popup.save(save_path, "PNG")
    print(f"생성 완료: {save_path}")


popups_data = [
    {
        "title": "[끝나지 않은 도전]",
        "subtitle": "1.7%의 아쉬움, 희망으로!",
        "body": [
            "• 서삼석 의원과 맞섰던 결기",
            "• 2022년 총선 1.7%의 아쉬움",
            "• 신안을 위한 마지막 헌신",
        ],
    },
    {
        "title": "[무너진 공정, 진실]",
        "subtitle": "정치 카르텔 불공정 심판!",
        "body": [
            "• 정치 카르텔의 공천 횡포 중단",
            "• 무죄 판명에도 이어진 배제",
            "• 오직 군민만을 바라보는 상식",
        ],
    },
    {
        "title": "[패거리 정치 타파]",
        "subtitle": "양심 있는 군수, 청렴 신안!",
        "body": [
            "• 채용 비리·측근 챙기기 타파",
            "• 20년 장기 집권의 구태 청산",
            "• 햇빛연금을 군민의 이익으로",
        ],
    },
]

if __name__ == "__main__":
    print("브랜딩 팝업 3종 생성 시작...\n")
    for i, data in enumerate(popups_data):
        generate_popup(i + 1, data["title"], data["subtitle"], data["body"])
    print(f"\n완료. '{OUTPUT_DIR}' 폴더를 확인하세요.")
