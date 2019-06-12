#!/usr/bin/env python3

import base64
import enum
import fcntl
import json
import os
import select
import signal
import socket
import struct
import sys
import time


room: str
nodeIds = []

rms: str
rmsIP: str
rmsPort: int


mts = None
mtsBuffer = None
mtsExpectedLen = 0

MtsOPL                  = 1
MtsLogin                = 2
MtsLoginResponse        = 3
MtsCommunicationKeyReq  = 4
MtsCommunicationKeys    = 5
MtsRoomsMap             = 7
MtsOplCommands          = 8
MtsFirmware             = 9

def MTSMessage(route, attributeRoute, jwt, data, reply):
  mtsMessage = { "route": route,
                 "attributeRoute": attributeRoute,
                 "jwt": jwt,
                 "data": data.decode("utf-8"),
                 "reply": reply }
  j = json.dumps(mtsMessage)
  return j

def MTSRoomsMap(roomNodeIds):
  global nodeIds
  print(roomNodeIds)
  nodeIds = roomNodeIds['NodeIds']
  for nd in nodeIds:
    print(nd)

def MTSOpl(opl):
  print('opl')
  # this is a raw opl message
  # if came from MTS, so it just needs to be forwarded to the
  # correct BT address...

def MTSSend(mtsMessage):
  global mts
  #print(mtsMessage)
  b = bytes(mtsMessage, 'utf-8')
  #print(b)
  l = len(b)
  h = l.to_bytes(4, byteorder='little')
  #print(h)
  d = h + b
  #print(d)
  mts.send(d)

def MTSReceive(data):
  #print('MTSReceive:', data)
  j = data.decode('utf-8')
  #print(j)
  mtsMessage = json.loads(j)
  #print(mtsMessage)
  reply = mtsMessage['data']
  #print(reply)
  repData = base64.b64decode(reply)
  #print(repData)
  if mtsMessage['route'] == MtsOPL: # OPL packets are tunneled through MTS
    MTSOPL(obj)
    return
  j = repData.decode('utf-8')
  #print(j)
  obj = json.loads(j)
  if mtsMessage['route'] == MtsRoomsMap:
    MTSRoomsMap(obj[0])
  else:
    print('MTSRoute %d not implemented' % (mtsMessage['route']))

def MTSBufferInit():
  global mtsBuffer, mtsBufferLen, mtsExpectedLen
  mtsBuffer = bytes(0)
  mtsBufferLen = 0
  mtsExpectedLen = 0


# Main
if len(sys.argv) != 3:
  print("usage: rmnd <room number> <rmsserverIP:rmsserverPort")
  sys.exit(1)

# Parse command line arguments
room = sys.argv[1]
rms = sys.argv[2]
x = rms.split(':')
rmsIP = x[0]
rmsPort = int(x[1])

print("RmNd Version 0.1 (Room: %s)" % room)

# connect to MTS server
while 1:
  mts = socket.socket()
  try:
    #print('connecting...')
    mts.connect((rmsIP, rmsPort))
    print('connected')
    break
  except Exception as e:
    print(e[1])
    time.sleep(2)
mts.setblocking(0)
fcntl.fcntl(sys.stdin, fcntl.F_SETFL, os.O_NDELAY)

# get our nodeIds
MTSBufferInit()
req = {"RoomName": room}
reqData = base64.b64encode(bytes(json.dumps(req), 'utf-8'))
mtsMessage = MTSMessage(MtsRoomsMap, None, "jwt", reqData, False)
#print('send %s' % (mtsMessage))
MTSSend(mtsMessage)



# set up bluetooth advertizing
  # note any devices that register...




# Wait for an incoming message...
eof = False
while 1:
  if eof:
    break

  r = [mts]
  try:
    r,_w,_e = select.select(r, [], [], 1)
  except Exception as e:
    print(e)
    break

  for f in r:
    if f == mts:
      try:
        data = mts.recv(1024)
        #print('received:', data)
        if mtsExpectedLen == 0:
          l = data[0:4]
          #print(l)
          mtsExpectedLen = int.from_bytes(l, "little")
          #print(mtsExpectedLen)
          data = data[4:]
        #print(data)
        mtsBuffer += data
        if (len(data) == mtsExpectedLen):
          MTSReceive(data)
          MTSBufferInit()
      except Exception as e:
        print(e)
        break
      if data == '':
        print('EOF from RMSServer')
        eof = True

