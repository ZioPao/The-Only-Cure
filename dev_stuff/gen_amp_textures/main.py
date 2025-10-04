from pathlib import Path
from PIL import Image

input_bodies_path = Path('input/body')
input_wound_texture = Path('input/wound.png')
# 48, 33 TEXTURE


# 256,256

IMG_WIDTH = 256


COORDS_L = {
    #"H": (0, 115),
    "F": (0, 59),
    "U": (0,21),
}

COORDS_R = {
    #"H": (IMG_WIDTH - 50- COORDS_L['H'][0], COORDS_L['H'][1]),
    "F": (IMG_WIDTH - 48 - COORDS_L['F'][0], COORDS_L['F'][1]),
    "U": (IMG_WIDTH - 48 - COORDS_L['U'][0], COORDS_L['U'][1]),
}

STATES = ["BOTH"]


overlay = Image.open(input_wound_texture)

for filepath in input_bodies_path.glob('*.png'):  # Only PNG files
    base = Image.open(filepath)
    body_name = filepath.stem


    for key_L, value_L in COORDS_L.items():
        for key_R, value_R in COORDS_R.items():
            for state in STATES:
                result = base.copy()

                if state == "BOTH" or state == "ONLY_LEFT":
                    result.paste(overlay, value_L, mask=overlay)
                if state == "BOTH" or state == "ONLY_RIGHT":
                    result.paste(overlay, value_R, mask=overlay)

                result.save(f'output/{body_name}_{key_L}_{key_R}_{state}.png')