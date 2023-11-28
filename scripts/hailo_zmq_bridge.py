import zmq
import json
import time

context = zmq.Context()
socket = context.socket(zmq.SUB)
socket.connect('tcp://127.0.0.1:5559')
socket.setsockopt(zmq.SUBSCRIBE, b'')

while True:
    try:
        msg = socket.recv(flags=zmq.NOBLOCK)
        msg = msg.decode()
        #print('==================')                                        
        #print('==================')                                        
        #print('==================')                                        
        #print("%s" % (msg))
        meta = json.loads(msg)
        if 'HailoROI' in meta:
            if 'SubObjects' in meta['HailoROI']:
                subobjs = meta['HailoROI']['SubObjects']
                for obj in subobjs:
                    if  'HailoDetection' in obj:
                        print('==================')                                        

                        det = obj['HailoDetection']
                        print('Detection, type: %s: conf: %f, x,y:(%f, %f), w,h:(%f, %f)' % (
                            det['label'],
                            det['confidence'],
                            det['HailoBBox']['xmin'],
                            det['HailoBBox']['ymin'],
                            det['HailoBBox']['width'],
                            det['HailoBBox']['height']))

                        if 'SubObjects' in det:
                            for detobj in det['SubObjects']:
                                for key in detobj.keys():
                                    print('Object type: %s' % key)
                                    if key == 'HailoClassification':
                                        if detobj[key]['classification_type'] == 'recognition_result':
                                            print('face recognized as: %s' % detobj[key]['label'])
                                    elif key == 'HailoUniqueID':
                                        print(detobj)

    except zmq.Again as e:
        pass
    time.sleep(0.010)                                            
