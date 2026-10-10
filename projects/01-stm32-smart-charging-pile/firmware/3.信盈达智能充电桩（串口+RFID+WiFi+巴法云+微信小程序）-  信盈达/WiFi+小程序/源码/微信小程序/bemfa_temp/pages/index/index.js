// index.js
// 获取应用实例
const app = getApp()

Page({
  data: {
    //需要修改的地方
    uid:"YOUR_BEMFA_UID",//用户密钥，巴法云控制台获取
    chargetopic:"charge",//传输温湿度的主题，创客云控制台创建
    device_status:"离线",// 显示led是否在线的字符串，默认离线
    chargeshow:"未连接",
    chargestate:"",//充电枪状态，默认为空
    money:"",//余额，默认为空
    chargeicon:"/utils/img/disconnect.png",//充电枪默认是断开
    dataTime:"", //记录数据上传的时间
    client: null,//mqtt客户端，默认为空
  },

//屏幕打开时执行的函数
  onLoad() {
    //检查设备是否在线
    this.getOnline()
    //获取服务器上现在存储的dht11数据
    this.getcharge()
    //设置定时器，每3秒请求一下设备状态
    setInterval(this.getcharge,2000)
    setInterval(this.getOnline,1000)
  },

  //请求设备状态,检查设备是否在线
  getOnline(){
    var that = this
     //api 接口详细说明见巴法云接入文档
    wx.request({
      url: 'https://api.bemfa.com/api/device/v1/status/?', //状态api接口，详见巴法云接入文档
      data: {
        uid: that.data.uid,
        topic: that.data.chargetopic,
      },
      header: {
        'content-type': "application/x-www-form-urlencoded"
      },
      success (res) {
        console.log(res.data)
        if(res.data.status == "online"){//如果在线
          that.setData({
            device_status:"在线"  //设置状态为在线
          })
        }else{                          //如果不在线
          that.setData({
            device_status:"离线",   //设置状态为离线
        
          })
        }
        console.log(that.data.device_status)
      }
    })    
  },

  getcharge(){
    //api 接口详细说明见巴法云接入文档
    var that = this
    wx.request({
      url: 'https://api.bemfa.com/api/device/v1/data/1/get/', //状态api接口，详见巴法云接入文档
      data: {
        uid: that.data.uid,
        topic: that.data.chargetopic,
        num:1
      },
      header: {
        'content-type': "application/x-www-form-urlencoded"
      },
      success (res) {
        console.log(res)
        if(res.data.msg.indexOf("#") != -1){//如果数据里包含#号，表示获取的是传感器值，因为单片机上传数据的时候用#号进行了包裹
          //如果有#号就进行字符串分割
          var all_data_arr = res.data.msg.split("#"); //分割数据，并把分割后的数据放到数组里。
          console.log(all_data_arr)//打印数组
          that.setData({ //数据赋值给变量
            chargestate:all_data_arr[2],    //
            money:all_data_arr[1],          //
            dataTime:res.data.time
          })
          if(all_data_arr[2]==1)
          {
            that.setData({ 
              chargeshow:"连接",    //
              chargeicon:"/utils/img/connect.png",
            })   
          } 
          if(all_data_arr[2]==0)
          {
            that.setData({ 
              chargeshow:"未连接",    
              chargeicon:"/utils/img/disconnect.png",//充电枪默认是断开
            })   
          }

        

        }
      }
    })    
  },
  //发送开关数据
  LedSendMsg(msg){
    wx.request({
      url: 'https://api.bemfa.com/api/device/v1/data/1/push/get/?', //状态api接口，详见巴法云接入文档
      data: {
        uid: this.data.uid,
        topic: this.data.ledtopic,
        msg:msg
      },
      header: {
        'content-type': "application/x-www-form-urlencoded"
      },
      success (res) {
      }
    })   
  },

})
