function load_blogs() {
    const container = document.querySelector('.Blogs');
    var xhr = new XMLHttpRequest();
    xhr.open('GET', 'http://' + window.location.hostname + ':5501/api/blogs', true);
    xhr.send();
    xhr.onreadystatechange = function () {
        if (xhr.readyState === 4) {
            if (xhr.status === 200) {
                const str = xhr.responseText;
                var data = JSON.parse(str);
                for(var i=0;i<Object.keys(data).length;i++)
                    {
                        const newItem = document.createElement('button');
                        console.log(data[i]['id']);
                        const id=data[i]['id']
                        newItem.addEventListener('click',function(){window.location="\\viewblog.html?id="+encodeURIComponent(id)});
                        newItem.className = 'Items';
                        newItem.innerHTML = `
                            <div class="title">${data[i]['title']}</div>
                            <div class="content">${data[i]['description']}<br><br></div>
                            <div class="date">${data[i]['publish-time']}<br><br></div>
                            
                        `;
                        container.appendChild(newItem);
                    }
            }
        }
    };
}
    /*xhr.onreadystatechange = function () {
    if(xhr.readyState === 4){
    if (xhr.status === 200 ) {
        console.log(xhr.responseText)
        const str=xhr.responseText;
        alert(str);
        var data = JSON.parse(str);
        for(var i=0;i<=Object.keys(data.Object).length;i++)
        {
            const newItem = document.createElement('div');
            newItem.className = 'Items';
            newItem.innerHTML = `
                <div class="title">项目标题${i}，仅用作DOM测试</div>
                <div class="content">项目内容${i}，没有博客仅用作DOM测试<br><br></div>
            `;
            container.appendChild(newItem);
        }
    }}
    };*/
