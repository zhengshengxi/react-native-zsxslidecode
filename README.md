# react-native-zsxslidecode

##简介：
滑动验证码，目前只支持iOS

![avatar](https://github.com/zhengshengxi/react-native-zsxslidecode/blob/master/ExampleImage/example.gif)


##安装：
####使用以下命令导入：
```
npm install react-native-zsxslidecode
```
####自动配置环境：
```react-native link``` 

or 

```react-native link react-native-zsxslidecode ```
##使用说明：
####import：
```
import ZSXSlideCode from 'react-native-zsxslidecode';
```
####开始使用：

```
<ZSXSlideCode style={{margin:0,height:280}}
            // imageBase64={''}
            // minimumTrackTintColor={'#000000'}
            // maximumTrackTintColor={'#000000'}
                          reStart={this.state.reStart}
                            onResult={(e)=>{
                                if (e.nativeEvent.result == true){
                                    //成功
                                }
                                else  {
                                    //失败
                                }
                                this.setState({result:e.nativeEvent.result,reStart:false})
                            }}
        />
```
###属性说明：
```
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
         * 重新开始验证 ：true
         *
         * */
        reStart: PropTypes.bool,

        /**
         * 验证结果回调 必须的
         * 返回 成功：true    失败：false
         * 取值: e.nativeEvent.result
         * */
        onResult:PropTypes.any.isRequired,
```
