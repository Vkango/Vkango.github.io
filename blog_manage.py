import json
from md2html import md2html
import os
from datetime import datetime
import shutil,time
process=md2html()
global json_object,json_text
json_object=[]
def read_json():
    try:
        with open(".\\src\\blog.json", 'r', encoding='utf-8') as json_file:
            global json_object,json_text
            json_text=json_file.read()
            json_object =json.loads(json_text)
            json_file.close()
    except:
        None
def write_json():
    with open(".\\src\\blog.json", 'w', encoding='utf-8') as json_file:
        global json_object,json_text
        json_text=json.dumps(json_object)
        json_file.write(json_text)
        json_file.close()
def search(search_text):
    for i in range(len(json_object)):
        if search_text in str(json_object[i]['id']) or search_text in str(json_object[i]['title']) or search_text in str(json_object[i]['description']):
            return {'found':True,'index':i}
    return{'found':False}
    

def generate_id():
    now = datetime.now()
    formatted_date = now.strftime("%Y%m%d")
    unique_id = f"{formatted_date}"
    path=unique_id[0:4]+"//"+unique_id[4:6]+"//"+unique_id[6:8]
    if not os.path.exists(".\\src\\blog\\"+unique_id[0:4]):
        os.mkdir(".\\src\\blog\\"+unique_id[0:4])
    if not os.path.exists(".\\src\\blog\\"+unique_id[0:4]+"\\"+unique_id[4:6]):
        os.mkdir(".\\src\\blog\\"+unique_id[0:4]+"\\"+unique_id[4:6])
    if not os.path.exists(".\\src\\blog\\"+unique_id[0:4]+"\\"+unique_id[4:6]+"\\"+unique_id[6:8]):
        os.mkdir(".\\src\\blog\\"+unique_id[0:4]+"\\"+unique_id[4:6]+"\\"+unique_id[6:8])
    
    entries = os.listdir(".\\src\\blog\\"+path)
    unique_id=str(unique_id)+str(len(entries)+1)
    path=unique_id[0:4]+"//"+unique_id[4:6]+"//"+unique_id[6:8]+"//"+str(len(entries)+1)+"at"+str(int(time.time()))
    if not os.path.exists(".\\src\\blog\\"+path):
        os.mkdir(".\\src\\blog\\"+path)
    return [unique_id,path]

    
def markdownToHTML(md_file_path,output_file):
    css_path = 'style_light.css'
    css_content = ""
    with open(css_path, 'r', encoding='utf-8') as css_file:
        css_content = css_file.read()
        css_file.close()
    with open(md_file_path, 'r', encoding='utf-8') as md_file:
        md_text = md_file.read()
        md_file.close()
    html = process.convert_md_to_html(md_text, True)
    styled_html = process.add_custom_style(html, css_content)
    with open(output_file, 'w', encoding='utf-8') as html_file:
        html_file.write(styled_html)
        html_file.close()
def searchBlog():
    """ search 的调用"""
    print("现在正在查找Blog，你可以输入：ID、标题 进行查找，支持模糊查找。")
    id_found=search(str(input()))
    return id_found
if __name__ == "__main__":
    while True:
        read_json()
        print("欢迎使用Blog编辑器 输入你想进行的操作\n1. 创建博客 2. 修改博客 3. 删除博客\n如需退出请输入其他内容。")
        i = int(input())
        if i == 1:
            ids=generate_id()
            print("请输入标题")
            title=input()
            print("请输入描述")
            desc=input()
            print("请输入Markdown文件路径")
            md_path=input()
            print("请输入封面图路径")
            pic_path=input()
            shutil.copy(pic_path,'.//src//Blog//'+ids[1]+'//banner.png')
            print("写入标签数据...")
            now=datetime.now()
            json2={'id':ids[0],'title':title,'publish-time':now.strftime("%Y/%m/%d %H:%M:%S"),'description':desc,'content':ids[1]}
            json_object.insert(0,json2)
            write_json()
            print("正在将Markdown转换为HTML")
            markdownToHTML(md_path,'.//src//Blog//'+ids[1]+'//src.html')
            print("写入HTML...")
            print("全部完成！")
        elif i == 2:
            id_found = searchBlog()
            if not id_found['found']:
                print("未找到对应Blog。")
            else:
                blog_id=id_found['index']
                print(f"以找到对应Blog。\n标题：{json_object[blog_id]['title']}\n描述：{json_object[blog_id]['description']}\n日期：{json_object[blog_id]['publish-time']}")
                while True:
                    print("选择修改项：1. 标题 2. 描述 3. 封面 4. 内容")
                    c=int(input())
                    if c==1:
                        print(f"原标题为：{json_object[blog_id]['title']}")
                        print("请在下面输入您希望修改成的标题：")
                        json_object[blog_id]['title']=input()
                        print("修改完成！")
                    elif c==2:
                        print(f"原描述为：{json_object[blog_id]['description']}")
                        print("请在下面输入您希望修改成的描述：")
                        json_object[blog_id]['description']=input()
                        print("修改完成！")
                    elif c==3:
                        print("请在下面输入您希望修改成的封面路径，支持拖放：")
                        shutil.copy(input(),'.//src//Blog//'+json_object[blog_id]['content']+'//banner.png')
                        print("修改完成！")
                    elif c==4:
                        print("请在下面输入新Markdown文件，支持拖放：")
                        print("正在将Markdown转换为HTML")
                        markdownToHTML(input(),'.//src//Blog//'+json_object[blog_id]['content']+'//src.html')
                        print("修改完成！")
                    
                    else:
                        print("以退出。")
                        break
                    write_json()
        elif i==3:
            id_found = searchBlog()
            if not id_found['found']:
                print("未找到对应Blog。")
            else:
                blog_id=id_found['index']
                print(f"以找到对应Blog。\n标题：{json_object[blog_id]['title']}\n描述：{json_object[blog_id]['description']}\n日期：{json_object[blog_id]['publish-time']}")
                print("确实要删除吗？(Y)")
                if input().upper()=="Y":
                    shutil.rmtree('.\\src\\blog\\'+json_object[blog_id]['content'])
                    del json_object[blog_id]
                    write_json()
                    print("以删除。但你的作案证据以被我录制😈。（假的")
        else:
            break
                

