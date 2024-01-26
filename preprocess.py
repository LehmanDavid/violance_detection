import cv2
import numpy as np
# C3D definition
from keras.models import Sequential, Model
from keras.layers import Dense, Dropout, Flatten, Conv3D, MaxPooling3D, ZeroPadding3D

# Utility functions for the experiments (chunk count, video preprocessing, feature computation, )
from keras.models import Model
import os
import cv2
import numpy as np


def process_video_for_prediction(video_path, frame_count=16, frame_size=(112, 112)):
    """
    Processes a video file for prediction.

    Parameters:
    - video_path: Path to the video file.
    - frame_count: Number of frames per video chunk (default is 16).
    - frame_size: Size to which each frame is resized (default is 112x112).

    Returns:
    - A numpy array of processed video chunks.
    """

    video = cv2.VideoCapture(video_path)
    frames = []

    while True:
        ret, frame = video.read()
        if not ret:
            break
        resized_frame = cv2.resize(frame, frame_size)
        frames.append(resized_frame)

    video.release()

    # Ensuring we have a complete last chunk by repeating the last frame
    while len(frames) % frame_count != 0:
        frames.append(frames[-1])

    # Reshape into chunks
    frame_chunks = np.array(frames).reshape(-1, frame_count, *frame_size, 3)

    return frame_chunks


def create_C3D_model(summary=False):
    """Creates model object with the sequential API: https://keras.io/models/sequential/

    Parameters
    ----------
    summary : bool
              if True, prints the model summary (default False)

    Returns
    -------
    model : Sequential
            The instantiated model
    """

    model = Sequential()
    input_shape = (16, 112, 112, 3)

    model.add(Conv3D(64, (3, 3, 3), activation='relu',
                     padding='same', name='conv1',
                     input_shape=input_shape))
    model.add(MaxPooling3D(pool_size=(1, 2, 2), strides=(1, 2, 2),
                           padding='valid', name='pool1'))
    # 2nd layer group
    model.add(Conv3D(128, (3, 3, 3), activation='relu',
                     padding='same', name='conv2'))
    model.add(MaxPooling3D(pool_size=(2, 2, 2), strides=(2, 2, 2),
                           padding='valid', name='pool2'))
    # 3rd layer group
    model.add(Conv3D(256, (3, 3, 3), activation='relu',
                     padding='same', name='conv3a'))
    model.add(Conv3D(256, (3, 3, 3), activation='relu',
                     padding='same', name='conv3b'))
    model.add(MaxPooling3D(pool_size=(2, 2, 2), strides=(2, 2, 2),
                           padding='valid', name='pool3'))
    # 4th layer group
    model.add(Conv3D(512, (3, 3, 3), activation='relu',
                     padding='same', name='conv4a'))
    model.add(Conv3D(512, (3, 3, 3), activation='relu',
                     padding='same', name='conv4b'))
    model.add(MaxPooling3D(pool_size=(2, 2, 2), strides=(2, 2, 2),
                           padding='valid', name='pool4'))
    # 5th layer group
    model.add(Conv3D(512, (3, 3, 3), activation='relu',
                     padding='same', name='conv5a'))
    model.add(Conv3D(512, (3, 3, 3), activation='relu',
                     padding='same', name='conv5b'))
    model.add(ZeroPadding3D(padding=((0, 0), (0, 1), (0, 1)), name='zeropad5'))
    model.add(MaxPooling3D(pool_size=(2, 2, 2), strides=(2, 2, 2),
                           padding='valid', name='pool5'))
    model.add(Flatten())
    # FC layers group
    model.add(Dense(4096, activation='relu', name='fc6'))
    model.add(Dropout(.5))
    model.add(Dense(4096, activation='relu', name='fc7'))
    model.add(Dropout(.5))
    model.add(Dense(487, activation='softmax', name='fc8'))

    if summary:
        print(model.summary())

    return model


def getFeatureExtractor(weigthsPath, layer, verbose=False):
    """Gets the C3D feature extractor

    Parameters
    ----------
    weightsPath : str
                  Pathname of the weights file for the C3D model.
    layer : str
            Name of the output layer for the feature extractor
    verbose : bool
              if True print debug logs (default True)

    Returns
    -------

    Model : Model class
            Feature extractor

    """

    model = create_C3D_model(verbose)
    model.load_weights(weigthsPath)
    model.compile(loss='mean_squared_error', optimizer='sgd')

    return Model(inputs=model.input, outputs=model.get_layer(layer).output)


def count_chunks(videoBasePath):
    """Counts the 16 frames lenght chunks available in a dataset organized in violent and non-violent,
    cam1 and cam2 folders, placed at videoBasePath.

    Parameters
    ----------
    videoBasePath : str
                    Base path of the dataset

    Returns
    -------
    cnt : int
          number of 16 frames lenght chunks in the dataset
    """

    folders = ['violent', 'non-violent']
    cams = ['cam1', 'cam2']
    cnt = 0

    for folder in folders:
        for camName in cams:
            path = os.path.join(videoBasePath, folder, camName)

            videofiles = os.listdir(path)
            for videofile in videofiles:
                filePath = os.path.join(path, videofile)
                video = cv2.VideoCapture(filePath)
                numframes = int(video.get(cv2.CAP_PROP_FRAME_COUNT))
                fps = int(video.get(cv2.CAP_PROP_FPS))
                chunks = numframes//16
                cnt += chunks

    return cnt


def preprocessVideos(videoBasePath, featureBasePath, verbose=True):
    """Preproccess all the videos.

    It extracts samples for the input of C3D from a video dataset, organised in violent and non-violent, cam1 and cam2 folders.
    The samples and the labels are store on two memmap numpy arrays, called samples.mmap and labels.mmap, at "featureBasePath".
    The numpy array with samples has shape (Chunk #, 16, 112, 112, 3), the labels array has shape (Chunk # 16, 112, 112, 3).
    For the AIRTLab dataset the number of chunks is 3537.

    Parameters
    ----------
    videoBasePath : str
                    Pathname to the base of the video repository, which contains two directories,
                    violent and non-violent, which are divided into cam1 and cam2.
    featureBasePath : str
                      it is the pathname of a base where the numpy arrays have to be saved.
    verbose : bool
              if True print debug logs (default True)

    """

    folders = ['violent', 'non-violent']
    cams = ['cam1', 'cam2']
    total_chunks = count_chunks(videoBasePath)
    npSamples = np.memmap(os.path.join(featureBasePath, 'samples.mmap'),
                          dtype=np.float32, mode='w+', shape=(total_chunks, 16, 112, 112, 3))
    npLabels = np.memmap(os.path.join(featureBasePath, 'labels.mmap'),
                         dtype=np.int8, mode='w+', shape=(total_chunks))
    cnt = 0

    for folder in folders:
        for camName in cams:
            path = os.path.join(videoBasePath, folder, camName)

            videofiles = os.listdir(path)
            for videofile in videofiles:
                filePath = os.path.join(path, videofile)
                video = cv2.VideoCapture(filePath)
                numframes = int(video.get(cv2.CAP_PROP_FRAME_COUNT))
                fps = int(video.get(cv2.CAP_PROP_FPS))
                chunks = numframes//16
                if verbose:
                    print(filePath)
                    print(
                        "*** [Video Info] Number of frames: {} - fps: {} - chunks: {}".format(numframes, fps, chunks))
                vid = []
                videoFrames = []
                while True:
                    ret, img = video.read()
                    if not ret:
                        break
                    videoFrames.append(cv2.resize(img, (112, 112)))
                vid = np.array(videoFrames, dtype=np.float32)
                filename = os.path.splitext(videofile)[0]
                chunk_cnt = 0
                for i in range(chunks):
                    X = vid[i*16:i*16+16]
                    chunk_cnt += 1
                    npSamples[cnt] = np.array(X, dtype=np.float32)
                    if folder == 'violent':
                        npLabels[cnt] = np.int8(1)
                    else:
                        npLabels[cnt] = np.int8(0)
                    cnt += 1

    if verbose:
        print("** Labels **")
        print(npLabels.shape)
        print('\n****\n')
        print("** Samples **")
        print(npSamples.shape)
        print('\n****\n')

    del npSamples
    del npLabels


def extractFeatures(weigthsPath, videoBasePath, featureBasePath='', verbose=True):
    """Extracts features from a video dataset, using fc6 of the C3D network.

    It extracts features from a video dataset, organized in violent and non-violent, cam1 and cam2 folders.

    Parameters
    ----------
    weightsPath : str
                  Pathname of the weights file for the C3D model.
    videoBasePath : str
                    Pathname to the base of the video repository, which contains two directories,
                    violent and non-violent, which are divided into cam1 and cam2.
    featureBasePath : str
                      if non-empty, it is the pathname of a base where numpy array has to be saved.
                      It assumes it is organized in violent, non-violent, cam1 and cam2 exactly as
                      the video repository (default '').
    verbose : bool
              if True print debug logs (default True)

    Returns
    -------
    X : numpy.ndarray
        Features array of shape (Num of video chunks, 4096) representing the 4096-dim feature vector for each video
        chunk in the dataset
    y : numpy.ndarray
        Labels array of shape (Num of video chunks) representing the labels for all the video chunks in the dataset
        (1 = violent, 2 = non violent)

    """

    featureExtractor = getFeatureExtractor(weigthsPath, 'fc6', verbose)

    folders = ['violent', 'non-violent']
    cams = ['cam1', 'cam2']
    labels = []
    features = []

    for folder in folders:
        for camName in cams:
            path = os.path.join(videoBasePath, folder, camName)
            featurepath = os.path.join(featureBasePath, folder, camName)

            videofiles = os.listdir(path)
            for videofile in videofiles:
                filePath = os.path.join(path, videofile)
                video = cv2.VideoCapture(filePath)
                numframes = int(video.get(cv2.CAP_PROP_FRAME_COUNT))
                fps = int(video.get(cv2.CAP_PROP_FPS))
                chunks = numframes//16
                if verbose:
                    print(filePath)
                    print(
                        "*** [Video Info] Number of frames: {} - fps: {} - chunks: {}".format(numframes, fps, chunks))
                vid = []
                videoFrames = []
                while True:
                    ret, img = video.read()
                    if not ret:
                        break
                    videoFrames.append(cv2.resize(img, (112, 112)))
                vid = np.array(videoFrames, dtype=np.float32)

                filename = os.path.splitext(videofile)[0]
                if featureBasePath:
                    featureFilePath = os.path.join(
                        featurepath, filename + '.csv')
                    with open(featureFilePath, 'ab') as f:
                        for i in range(chunks):
                            X = vid[i*16:i*16+16]
                            out = featureExtractor.predict(np.array([X]))
                            np.savetxt(f, out)
                            out = out.reshape(4096)
                            features.append(out)
                            if folder == 'violent':
                                labels.append(1)
                            else:
                                labels.append(0)

                    if verbose:
                        print('*** Saved file: ' + featureFilePath)
                        print('\n')
                else:
                    for i in range(chunks):
                        X = vid[i*16:i*16+16]
                        out = featureExtractor.predict(np.array([X]))
                        out = out.reshape(4096)
                        features.append(out)
                        if folder == 'violent':
                            labels.append(1)
                        else:
                            labels.append(0)

    y = np.array(labels)
    X = np.array(features)

    if verbose:
        print("** Labels **")
        # print(y)
        print(y.shape)
        print('\n****\n')
        print("** Features **")
        # print(X)
        print(X.shape)
        print('\n****\n')

    return X, y


def get_labels_and_features_from_files(basePath, verbose=True):
    """"Generates the feature array and the labels from saved feature files.

    It generates features and labels from saved features files, organised in violent and
    non-violent, cam1 and cam2 folders.

    Parameters
    ----------
    basePath : str
               Pathname to the base of the feature files repository, which contains two directories,
               violent and non-violent, which are divided into cam1 and cam2.
    verbose : bool
              if True print debug logs (default True)

    Returns
    -------
    X : numpy.ndarray
        Features array of shape (Num of video chunks, 4096) representing the 4096-dim feature vector for each video
        chunk in the dataset
    y : numpy.ndarray
        Labels array of shape (Num of video chunks) representing the labels for all the video chunks in the dataset
        (1 = violent, 2 = non violent)

    """

    folders = ['violent', 'non-violent']
    cams = ['cam1', 'cam2']
    labels = []
    features = []

    for folder in folders:
        for camName in cams:
            path = os.path.join(basePath, folder, camName)

            textfiles = os.listdir(path)
            for textfile in textfiles:
                filePath = os.path.join(path, textfile)
                chunks = np.loadtxt(filePath)
                for chunk in chunks:
                    features.append(chunk)
                    if folder == 'violent':
                        labels.append(1)
                    else:
                        labels.append(0)

    y = np.array(labels)
    X = np.array(features)

    if verbose:
        print("** Labels **")
        # print(y)
        print(y.shape)
        print('\n****\n')
        print("** Features **")
        # print(X)
        print(X.shape)
        print('\n****\n')

    return X, y
