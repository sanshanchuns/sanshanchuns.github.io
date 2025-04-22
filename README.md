# 个人博客网站

这是一个基于 Jekyll 构建的个人博客网站，使用了 Jasper 主题。网站包含了博客文章展示、URL Scheme 快速启动等功能。

## 功能特点

- 响应式设计，适配各种设备
- 支持文章分类和标签
- 支持多作者
- 内置 URL Scheme 快速启动功能，可以快速打开常用应用
- 支持 RSS 订阅
- 支持 Google Analytics 统计

## URL Scheme 快速启动

网站集成了以下应用的快速启动功能：

- 微信 (weixin://)
- 抖音 (snssdk1128://)
- 支付宝 (alipay://)
- QQ (mqq://)
- 电话 (tel:)
- 邮件 (mailto:)

## 技术栈

- Jekyll 3.0.0
- HTML5
- CSS3
- JavaScript
- jQuery
- Google Analytics

## 本地开发

1. 安装 Ruby 和 Jekyll
2. 克隆项目
3. 安装依赖：
   ```bash
   bundle install
   ```
4. 启动本地服务器：
   ```bash
   bundle exec jekyll serve
   ```
5. 访问 http://localhost:4000

## 部署

1. 构建静态文件：
   ```bash
   bundle exec jekyll build
   ```
2. 将 `_site` 目录下的文件部署到您的服务器

## 许可证

MIT License

## 联系方式

如有任何问题或建议，欢迎通过以下方式联系：

- 邮箱：[your-email@example.com]
- GitHub：[your-github-username] 