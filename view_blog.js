function getQueryParam(param) {
    const queryParams = new URLSearchParams(window.location.search);
    return queryParams.get(param);
  }
  
function viewblog()
{
    let id=getQueryParam('id');
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'http://' + window.location.hostname + ':5501/api/view/'+id, true);
    xhr.send();
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                const str = xhr.responseText;
                var data = JSON.parse(str);
                document.title=data['title']+" - Blog";
                document.getElementById('article-title').innerText=data['title'];
                document.getElementById('article-desc').innerText=data['description'];
                document.getElementById('article-publish-time').innerText=data['publish-time'];
                document.getElementById('img_bgr').setAttribute('src','src//blog//'+data['content']+'\\banner.png')
                document.getElementById('content').innerHTML=data['html_raw'];
            }
        }
    };
}