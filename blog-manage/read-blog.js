const http = require('http');
function enumBlog() {
    return new Promise((resolve, reject) => {
        const fs = require('fs');
        fs.readFile('./src/blog.json', 'utf8', (err, data) => {
            if (err) {
                console.error('cannot read blog.', err);
                reject(err);
                return;
            }
            try {
                const json_data = JSON.parse(data);
                resolve(json_data);
            } catch (err) {
                console.error('解析错误：', err);
                reject(err);
            }
        });
    });
}
function blog_html(id) {
    return new Promise((resolve, reject) => {
        const fs = require('fs');
        fs.readFile('./src/blog/'+id+'//src.html', 'utf8', (err, data) => {
            if (err) {
                console.error('cannot read blog.', err);
                reject(err);
                return;
            }
            try {
                resolve(data);
            } catch (err) {
                console.error('解析错误：', err);
                reject(err);
            }
        });
    });
}
const server = http.createServer(async (req, res) => {
  if (req.url === '/api/blogs' && req.method === 'GET') {
    res.setHeader('Access-Control-Allow-Origin', '*');
    res.writeHead(200, { 'Content-Type': 'application/json' });
    try {
        const json_data = await enumBlog(); // 等待 enumBlog 完成
        res.end(JSON.stringify(json_data));
    } catch (err) {
        res.end('读取或解析博客时出错：'+ err);
    }

  } 
  
  
  else if (req.url.startsWith('/api/view/') && req.method === 'GET') {

    res.setHeader('Access-Control-Allow-Origin', '*');
    res.writeHead(200, { 'Content-Type': 'application/json' });
    id=req.url.replace('/api/view/','');
    try {
        const json_data = await enumBlog();
        const blogById = json_data.find(blog => blog.id == id);
        if (blogById) {
            const html_raw=await blog_html(blogById['content']);
            blogById.html_raw=html_raw;
            res.end(JSON.stringify(blogById));}
        }
     catch (err) {
        res.end('failed:'+ err);
    }
  } 
  
  else {
    res.writeHead(404, { 'Content-Type': 'application/json' });
    res.end(JSON.stringify({ error: 'Not found' }));
  }
});
const port = 5501;

server.listen(port, () => {
  console.log(`Server running at http://localhost:${port}/`);
});



