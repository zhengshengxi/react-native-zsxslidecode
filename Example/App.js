/**
 * Sample React Native App
 * https://github.com/facebook/react-native
 * @flow
 */

import React, { Component } from 'react';
import {
  Platform,
  StyleSheet,
  Text,
  View
} from 'react-native';
import ZSXSlideCode from 'react-native-zsxslidecode'

const instructions = Platform.select({
  ios: 'Press Cmd+R to reload,\n' +
    'Cmd+D or shake for dev menu',
  android: 'Double tap R on your keyboard to reload,\n' +
    'Shake or press menu button for dev menu',
});

type Props = {};
export default class App extends Component<Props> {
    constructor(props){
        super(props);
        this.state = {
            result:false,
        }
    }
    render() {
        return (
            <View>
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
                <Text style={styles.welcome}>验证{this.state.result==true?'成功':'请拖动滑块完成拼图'}</Text>
            </View>
        );
    }
}

const styles = StyleSheet.create({
  container: {
    flex: 1,
    justifyContent: 'center',
    alignItems: 'center',
    backgroundColor: '#F5FCFF',
  },
  welcome: {
    fontSize: 20,
    textAlign: 'center',
    margin: 10,
  },
  instructions: {
    textAlign: 'center',
    color: '#333333',
    marginBottom: 5,
  },
});
