from pathlib import Path
from PIL import Image
import os

input_bodies_path = Path('input/body')
input_wound_texture = Path('input/wound.png')
# 45, 33 TEXTURE


# 256,256

IMG_WIDTH = 256

COORDS_L = {
    "H": (2, 100),
    "F": (2, 59),
    "U": (2,21),
}

COORDS_R = {
    "H": (IMG_WIDTH - 43- COORDS_L['H'][0], COORDS_L['H'][1]),
    "F": (IMG_WIDTH - 43 - COORDS_L['F'][0], COORDS_L['F'][1]),
    "U": (IMG_WIDTH - 43 - COORDS_L['U'][0], COORDS_L['U'][1]),
}

FULL_COORDS = {key: (COORDS_L[key], COORDS_R[key]) for key in COORDS_L}

print(FULL_COORDS)
overlay = Image.open(input_wound_texture)

for filepath in input_bodies_path.glob('*.png'):  # Only PNG files
    print(f'Processing {filepath.name}...')
    base = Image.open(filepath)


    body_name = filepath.stem.replace('MaleBody', 'skin')
    if body_name.endswith('a'):
        body_name = body_name[:-1] + '_hairy_b'
    else:
        body_name = body_name + '_b'

    for key, (value_L, value_R) in FULL_COORDS.items():
        print(key)
        result = base.copy()
        
        result.paste(overlay, value_L, mask=overlay)
        result.paste(overlay, value_R, mask=overlay)

        output_path = 'output/'

        if key == "H":
            os.makedirs('output/Hand', exist_ok=True)
            output_path = 'output/Hand'

        if key == "F":
            os.makedirs('output/Forearm', exist_ok=True)
            output_path = 'output/Forearm'
        
        if key == "U":
            os.makedirs('output/UpperArm', exist_ok=True)
            output_path = 'output/UpperArm'

        result.save(f'{output_path}/{body_name}.png')


