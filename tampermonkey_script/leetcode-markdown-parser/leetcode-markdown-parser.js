// ==UserScript==
// @name         leetcode-markdown-parser
// @namespace    https://gitee.com/tomocat/cat-script
// @version      1.0
// @description  parse leetcode prob from html to markdown
// @author       tomocat
// @match        https://leetcode.cn/problems/*
// @icon         https://gitee.com/tomocat/cat-script/raw/master/tampermonkey_script/source/icon_cat.ico
// @require      https://cdn.staticfile.org/jquery/3.4.1/jquery.min.js
// @require      https://unpkg.com/sweetalert/dist/sweetalert.min.js
// @require      http://code.jquery.com/jquery-3.x-git.min.js
// @require      https://gitee.com/tomocat/cat-script/raw/master/mirror/waitForKeyElements/waitForKeyElements.js
// @grant        GM_registerMenuCommand
// @grant        GM_setClipboard
// @grant        unsafeWindow
// ==/UserScript==

// 解决eslint中waitForKeyElements未定义的报错
/* globals jQuery, $, waitForKeyElements, swal */

(function () {
    'use strict';

    // 存储题目内容的markdown字符串
    var contentStr = "";

    String.prototype.replaceAll = function (s1, s2) {
        return this.replace(new RegExp(s1, "gm"), s2);
    };


    GM_registerMenuCommand("将LeetCode题目复制为MarkDown", function () {
        // 获取网页元素
        // 1) title: 标题
        // 2) difficulty: 难度
        // 3) contentDom: 题目内容的DOM树
        var title = $("#question-detail-main-tabs > div.css-1qqaagl-layer1.css-12hreja-TabContent.e16udao5 > div > div.css-xfm0cl-Container.eugt34i0 > h4 > a").text();
        var difficulty = "难度: " + $("#question-detail-main-tabs > div.css-1qqaagl-layer1.css-12hreja-TabContent.e16udao5 > div > div.css-xfm0cl-Container.eugt34i0 > div > span:nth-child(2)").text();
        var contentDom = $("#question-detail-main-tabs > div.css-1qqaagl-layer1.css-12hreja-TabContent.e16udao5 > div > div.css-1rngd9y-ZoomWrapper.e13l6k8o9 > div > div");

        console.log("title: ", title);
        console.log("difficulty: ", difficulty);
        console.log("contentDom: ", contentDom);

        // 遍历contentDom中每个元素, 将html格式解析成markdown格式
        contentDom.children().each(function () {
            parseDom($(this));
        });

        var res = "# " + title + "\n ## 题目 \n" + difficulty + "\n" + contentStr +
            "来源: 力扣（LeetCode）\n链接: " + unsafeWindow.location.href +
            "\n著作权归领扣网络所有。商业转载请联系官方授权，非商业转载请注明出处。";
        console.log("解析结果:\n" + res);

        // 将解析出的markdown字符串写入剪贴板
        GM_setClipboard(res);

        // 解析成功的弹出框
        swal({
            icon: "success",
            title: "复制成功",
        });
    });

    /**
     * 功能: 将dom树中的内容解析成markdown
     */
    function parseDom(dom) {
        var elem = dom[0];
        console.log("DEBUG::parse.element::", elem);
        switch (elem.tagName) {
            // 文本框
            case "P":
                contentStr += "\n" + parseHtml2Markdown(elem.innerHTML) + "\n";
                break;
            // 代码框
            case "PRE":
                contentStr += "\n```\n" + elem.innerText + "\n```\n\n";
                break;
            case "OL":
                alert("暂未支持的标签OL");
                break;
            // 列表框
            case "UL":
                var ulHtml = '\n';
                dom.children().each(function () {
                    ulHtml += '- ' + parseHtml2Markdown($(this).html()) + '\n';
                });
                ulHtml += '\n';
                contentStr += ulHtml
                break;
            case "DIV":
                alert("未完全支持的标签DIV");
                dom.children().each(function () {
                    parseDom($(this));
                });
                break;
            case "IMG":
                contentStr += "\n" + new String(elem.outerHTML) + "\n";
                break;
            default:
                alert("未提前定义的标签: ", elem.tagName);
                console.log("未提前定义的标签: ", elem.tagName);
                console.log("元素内容:\n", elem.outerHTML);
                console.log($(elem));
                contentStr += "\n" + new String(elem.outerHTML) + "\n";
                break;
        }
    }

    /**
     * 功能: 将html格式的文本解析成markdown字符串
     */
    function parseHtml2Markdown(html) {
        // 空格
        html = html.replaceAll(/&nbsp;/, ' ');
        // 换行
        // html = html.replaceAll(/<br\s*(\/)*>/, '\n\n');
        // 小于符号
        html = html.replaceAll(/&lt;/, '<');
        // 大于符号
        html = html.replaceAll(/&gt;/, '>');
        // 加粗
        html = html.replaceAll(/<strong>/, '**');
        html = html.replaceAll(/<\/strong>/, '**');
        html = html.replaceAll(/<b>/, '**');
        html = html.replaceAll(/<\/b>/, '**');
        // 去掉空的加粗块
        html = html.replaceAll(/\*\*\s+\*\*\s+/, '');
        // 去掉行内代码块
        html = html.replaceAll(/<[/]{0,1}code>/, '');
        // 下标
        // html = html.replaceAll(/<sub>/, '$_{');
        // html = html.replaceAll(/<\/sub>/, '}$');

        // 上标
        // html = html.replaceAll(/<sup>/, '$^{');
        // html = html.replaceAll(/<\/sup>/, '}$');

        return html
    }
})();