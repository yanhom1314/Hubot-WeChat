# Description:
#   Allows Hubot to interact with turing rebot http://www.tuling123.com/.
#
# Commands:
#   hubot turing|图灵 .*

module.exports = (robot) ->
  robot.hear /(turing|图灵|图图|米图|mitu) (.*)/i, (msg) ->
    turingRobot msg

turingRobot = (msg) ->
  isZhCn = msg.match[1] is "图灵"
  info = new Buffer msg.match[2]
  #key = "879a6cb3afb84dbf4fc84a1df2ab7319" // for baidu apis
  key = "ca1afed84db30a7818aa5928db95c366"
  userid = "eb2edb736"
  params = "key=#{key}&info=#{info}&userid=#{userid}"
  #urlPath = "http://apis.baidu.com/turing/turing/turing?#{params}" // for baidu apis
  urlPath = "http://www.tuling123.com/openapi/api?#{params}"
  req = msg.http(urlPath)
  #req.header "apikey", "9b2eeae160264cd314dcc44dd081544b" // for baidu apis
  req.get() (err, res, body) ->
    getRandomItem = (length) ->
      return Math.floor(Math.random(0, 1) * length)
    sendMsgByCode =
      "100000": (msg, jsonBody) ->
                  msg.send "#{jsonBody.text}"
      "200000": (msg, jsonBody)->
                  msg.send "#{jsonBody.text}\n#{jsonBody.url if jsonBody.url}"
      "302000": (msg, jsonBody)->
                  randomIdx = getRandomItem jsonBody.list.length
                  item = jsonBody.list[randomIdx]
                  msg.send "#{jsonBody.text}\n#{item.article} from #{item.source}\n#{item.detailurl}"
      "308000": (msg, jsonBody)->
                  randomIdx = getRandomItem jsonBody.list.length
                  item = jsonBody.list[randomIdx]
                  msg.send "#{jsonBody.text}\n#{item.name}\n#{item.info}\n#{item.detailurl}"
    switch res.statusCode
      when 200
        jsonBody = JSON.parse body
        if sendMsgByCode.hasOwnProperty jsonBody.code
          sendMsgByCode[jsonBody.code] msg, jsonBody
      when 404
        if isZhCn
          msg.send "为啥图灵不理我: #{res.statusCode}"
        else
          msg.send "Why no response: #{res.statusCode}"
      else
        msg.send "Debug: #{res.statusCode}"