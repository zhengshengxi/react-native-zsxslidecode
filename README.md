# react-native-zsxslidecode

##简介：
滑动验证码，目前只支持iOS

![Alt text](react-native-zsxslidecode/ExampleImage/example.gif "optional title")

##安装：
####使用以下命令导入
```
npm install react-native-zsxslidecode
```
##使用：
####先import：
```
import ZSXSlideCode from 'react-native-zsxslidecode';
```
####开始使用：

```
<ZSXSlideCode style={{margin:0,height:280}}
            // imageBase64={''}
            // minimumTrackTintColor={'#000000'}
            // maximumTrackTintColor={'#000000'}
                            onResult={(e)=>{
                                if (e.nativeEvent.result == true){
                                    //成功
                                }
                                else  {
                                    //失败
                                }
                                this.setState({result:e.nativeEvent.result,})
                            }}
        />
```