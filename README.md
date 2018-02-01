# muxproxy
可以动态配置的反向代理服务器。

# API 接口定义
## 数据模型
### prefix
代表某个反代的信息。

```json
{
    "upstream": [
        "http://2.3.3.3/myapp/",
        "http://6.6.6.6/myapp/"
    ],
    "request_header": {
        "Host": "myapp.gov.cn"
    },
    "response_header": {
        "Access-Control-Allow-Origin": "*"
    }
}
```

上面的这个 `prefix`：
* 定义了两个后端服务器。muxproxy 会根据请求次数做负载均衡，目前没有实现权重。
* 定义了一个附加请求头，这个请求头会被传给 upstream。
* 定义了一个附加响应头，这个响应头会被传给客户端。

### 错误码
出错信息，`0` 表示没有出错，其他值表示出错。
如果出错，还会出现 `msg`，表示具体的错误信息。

## API
### `GET` `/prefix/`
获取所有 `prefix`。

```json
{
    "error": 错误码,
    "msg": 错误信息,
    "data": {
        "prefix1": {prefix1},
        "prefix2": {prefix2}
    }
}
```

### `GET` `/prefix/{prefix-name}`
获取某个 `prefix`，名字是 `prefix-name`。

```json
{
    "error": 错误码,
    "msg": 错误信息,
    "data": {prefix-name}
}
```

### `PUT` `/prefix/{prefix-name}`
提交或替换一个 `prefix`，request body 是 json 编码的 `prefix` 数据。

### `DELETE` `/prefix/`
删除所有数据。

### `DELETE` `/prefix/{prefix-name}`
删除某个 `prefix`。
