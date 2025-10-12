from pathlib import Path
from PIL import Image
import os

input_bodies_path = Path('input/body')
input_bandages_path = Path('input/bandages')

for body_filepath in input_bodies_path.glob('*.png'):  # Only PNG files
    for bandage_filepath in input_bandages_path.glob('*.png'):  # Only PNG files
        print(f'Processing {body_filepath.name} with {bandage_filepath.name}...')
        base = Image.open(body_filepath)
        overlay = Image.open(bandage_filepath)

        body_name = body_filepath.stem.replace('MaleBody', 'skin')
        if body_name.endswith('a'):
            body_name = body_name[:-1] + '_hairy_b'
        else:
            body_name = body_name + '_b'

        result = base.copy()
        result.paste(overlay, (0, 0), mask=overlay)  # Use overlay as its own mask

        if bandage_filepath.stem == 'MaleBody01_bandages_lower_arm':
            output_path = 'output/Bandaged/Forearm/'
        elif bandage_filepath.stem == 'MaleBody01_bandages_upper_arm':
            output_path = 'output/Bandaged/UpperArm/'
        elif bandage_filepath.stem == 'MaleBody01_bandages_lower_arm_blood':
            output_path = 'output/Bandaged_Bloody/Forearm/'
        elif bandage_filepath.stem == 'MaleBody01_bandages_upper_arm_blood':
            output_path = 'output/Bandaged_Bloody/UpperArm/'


        os.makedirs(output_path, exist_ok=True)
        result.save(f'{output_path}/{body_name}.png') 

