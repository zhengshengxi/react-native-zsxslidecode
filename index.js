import React, { Component } from 'react';
import { requireNativeComponent } from 'react-native';
import PropTypes from 'prop-types';
var ViewManager = requireNativeComponent('ZSXSlideCode', ZSXSlideCode);

export class ZSXSlideCode extends Component {
    static propTypes = {
        /**
         * base64编码后的图片，字符串格式
         *
         * */
        imageBase64: PropTypes.string,

        /**
         * base64编码后的滑动按钮图片，字符串格式
         *
         * */
        buttonImageBase64: PropTypes.string,

        /**
         * 滑条左边颜色
         *
         * */
        minimumTrackTintColor: PropTypes.string,

        /**
         * 滑条右边颜色
         *
         * */
        maximumTrackTintColor: PropTypes.string,

        /**
         * 验证结果回调 必须的
         * 返回 成功：true    失败：false
         * 取值: e.nativeEvent.result
         * */
        onResult:PropTypes.any.isRequired,
    }
    render() {
        return <ViewManager {...this.props}/>;
    }
}

module.exports = ZSXSlideCode;