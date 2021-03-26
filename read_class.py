"""
@Date    : 2021-03-05
@Author  : liyachao
"""
import os, re, json

root_dir = "."
file_name_list = [
    "./AsheniOS/Test.h"
]

NSInteger = "NSInteger"
NSUInteger = "NSUInteger"
enum_dic = {
    "enum": NSInteger,
    }


def get_method_name(method_str: str):
    """

    :param method_str:
    :return:
    """
    method_name = re.sub(r'\([^()]*\)', "", method_str)
    method_name = re.sub(r'\((.*?)\)', "", method_name)
    return method_name


def get_method_dic(method_str):
    return_dic = dict()
    _method_str = method_str.strip()

    # 先获取返回值
    return_type = re.findall(r"\((.*?)\)", _method_str)[0].strip()
    return_dic["return_type"] = return_type.strip()[:-1].strip() if return_type.endswith("*") else return_type
    # 把换行替换成空格
    _method_str = _method_str.replace("\n", " ")

    # 切参数_method_str
    while "  " in _method_str:
        _method_str = _method_str.replace("  ", " ")
    return_dic["interface_name"] = get_param(get_method_name(_method_str))
    print(_method_str)
    return_dic["param_type_list"] = get_param_type(_method_str)
    return_dic["param_list"] = get_param_name_list(_method_str)
    return return_dic


def get_param_name_list(method_str):
    _method_name = re.sub(r'\([^()]*\)', "", method_str)
    method_name1 = re.sub(r'\((.*?)\)', "", _method_name)
    _param_list = method_name1.split(" ")
    _rep_param_list = list()
    for index in _param_list:
        _rep_param_list.append(index.split(":")[-1])
    return _rep_param_list


def get_param(method_str):
    param_list = list()
    for index in method_str.split(" "):
        param_list.append(index.split(":")[0])
    return "/{}:".format(":".join(param_list))


def get_param_type(method_str):
    param_type_str_list = list()
    for index in method_str.split(":"):
        param_type_str_list.append(re.findall(r"\((.*)\)", index)[0])

    param_type_str_list.pop(0)
    param_type_list = list()
    for index in param_type_str_list:
        index = re.sub(r"\^(.*?)\)", "^)", index)
        if "^)" in index:
            block_param = re.sub(r"\(|\)", "", index.split("^)")[-1]).split(",")
            block_param_list = list()
            for _index in block_param:
                _block_index = _index.strip().split(" ")
                if len(_block_index) > 1:
                    _param = "".join(_block_index[:-1])
                else:
                    _param = "".join(_block_index[0])
                if _param in enum_dic.keys():
                    block_param_list.append(enum_dic[_param])
                else:
                    block_param_list.append(_param)
            block_name = "block_{}".format("_".join(block_param_list))
            param_type_list.append(block_name)
        else:
            if index in enum_dic.keys():
                param_type_list.append(enum_dic[index])
            elif len(index.split(" ")) > 1:
                param_type_list.append("".join(index.split(" ")[:-1]))
            else:
                param_type_list.append("".join(index.split(" ")[0]))
    return param_type_list


def get_file_dic(file_name):
    with open(file_name, "r") as file:
        data = file.read()
    # 去除注释
    data = re.sub(r'#(.*?)\n|//(.*?)\n|\t', "", data)
    annotation_comment = re.compile(r'/\*\*(.*?)\*/|/\*!(.*?)\*/|/\*(.*?)\*/', re.DOTALL)
    annotation_result = annotation_comment.sub("", data)

    # 获取函数列表
    method_comment = re.compile(r'-(.*?);', re.DOTALL)
    method_result = method_comment.findall(annotation_result)
    method_list = list()
    for _index in method_result:
        method_list.append(get_method_dic(_index))
    return method_list


if __name__ == "__main__":
    class_json_file = "{}/AshenClass.json".format(os.path.abspath(root_dir))
    class_dic = dict()
    for index in file_name_list:
        class_dic[index.split("/")[-1]] = get_file_dic(index)
    class_json = json.dumps(class_dic, sort_keys=True, indent=4, separators=(', ', ': '))
    with open(class_json_file, "w+") as file:
        file.write(class_json)
    print(class_json)

