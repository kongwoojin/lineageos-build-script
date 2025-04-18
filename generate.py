import glob
import os
import sys

def get_file_size(file_path: str) -> int:
    return os.path.getsize(file_path)

def generate_ota_json(datetime: int, file_name: str, id: str, size: int):
    tmp = file_name.split("-")
    
    if len(tmp) < 5:
        raise ValueError("Filename format is incorrect")

    version = tmp[1]
    romtype = tmp[3].lower() 
    device = tmp[4].replace(".zip","")

    url = f"https://dl.kongjak.com/{device}/LineageOS/{version}/{file_name}"

    return f"""{{
        "response": [
            {{
                "datetime": {datetime},
                "filename": "{file_name}",
                "id": "{id}",
                "romtype": "{romtype}",
                "size": {size},
                "url": "{url}",
                "version": "{version}"
            }}
        ]
    }}"""

def read_builddate(out_dir: str):
    date_file = glob.glob(f'{out_dir}/build_date.txt')[0]
    with open(date_file, 'r') as f:
        return int(f.readline())

def read_sha256sum(out: str):
    hash_file = glob.glob(out + 'lineage-*.sha256sum')[0]
    with open(hash_file, 'r') as f:
        hash, file_name = f.readline().split()
        return hash, file_name

def write_json(json: str, device: str):
    f = open(f'{device}.json', "w")
    f.write(json)
    f.close()


def main(device: str, out_dir: str):
    out = f'{out_dir}/target/product/{device}/'
    hash, file_name = read_sha256sum(out)
    file_size = get_file_size(out + file_name)
    ota_json = generate_ota_json(read_builddate(out_dir), file_name, hash, file_size)
    write_json(ota_json, device)

if __name__ == "__main__":
    device = sys.argv[1]
    out_dir = sys.argv[2]
    main(device, out_dir)
