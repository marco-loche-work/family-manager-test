from typing import List
from robot.api.deco import keyword

@keyword
def find_in_list(list_to_find: List[dict], field_name: str, field_value: any):
    print('field_name = ' + field_name)
    print('field_value = ' + field_value)
    values = [x for x in list_to_find if x.get(field_name) == field_value]
    if values:
        return values[0]