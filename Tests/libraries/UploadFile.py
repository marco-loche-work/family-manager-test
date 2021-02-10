import requests
import json
import os

from robot.api.deco import keyword

@keyword
def upload_csv(url: str, file_path: str, expected_status=200):
    return upload_file(url, file_path, "text/csv", expected_status)

@keyword
def upload_excel(url: str, file_path: str, expected_status=200):
    return upload_file(url, file_path, "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet", expected_status)


def upload_file(url: str, file_path: str, file_type: str, expected_status=200):
    files = {'file': (os.path.basename(file_path), open(file_path, 'rb'), file_type)}    
    r = requests.post(url, files=files, verify=False)
    assert  r.status_code == expected_status, "Status !=" + str(expected_status) + " (" + str(r.status_code) + ")"
    return r
