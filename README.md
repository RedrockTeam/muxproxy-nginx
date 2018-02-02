# muxproxy
可以动态配置的反向代理服务器。
配置信息直接存放在 Nginx 的共享内存中，reload 不会消失，restart 会消失。

# 部署方式
0. 将 utils.lua manage.lua proxy.lua 放置到 /usr/local/share/muxproxy 目录下
0. 将 nginx.conf 包含到 nginx 配置文件的 http context 中

# API 接口定义
API 均为 HTTP API，传递的数据均使用 JSON 编码，放在 http request 和 response 的 body 中。

API 接口需要带上一个 header，`X-Muxproxy-Auth: xxx` 作为认证信息。
它的值可以在 nginx.conf 里配置。

## 数据模型
### prefix
代表某个反代的信息。

```json
{
    "upstream": [
        "http://2.3.3.3/myapp$path",
        "http://6.6.6.6/myapp$path"
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
* 定义了两个后端服务器，根据请求次数做负载均衡，目前没有实现权重
* 定义了一个附加请求头，这个请求头会被传给 upstream
* 定义了一个附加响应头，这个响应头会被传给客户端

#### upstream URL 格式
upstream URL 中可以包含变量，目前可用的变量分别是：

变量名 | 解释
---- | ----
`$path` | 原始 url 中 `/api/{prefix-name}` 之后的内容，以 `/` 开头
`$prefix` | 原始 url 中的 `{prefix-name}`，以 `/` 开头
`$api_prefix` | 原始 url 中 `{prefix-name}` 之前的部分

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

# TODO
* 数据持久化
* 提高匹配性能
* 使用更高性能的序列化方案

