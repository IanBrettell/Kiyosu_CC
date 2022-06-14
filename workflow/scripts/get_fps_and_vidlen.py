# singularity shell /hps/nobackup/birney/users/ian/containers/Kiyosu_CC/opencv_4.5.1.sif

import os
import cv2 as cv
from glob import glob

in_dir = "/hps/nobackup/birney/users/ian/Kiyosu_CC/raw_videos"
glob_pattern = os.path.join(in_dir, '*')

vids = glob(glob_pattern)
# Check it's in order
print(*vids, sep="\n")

fps_list = []
vid_lens = []

for vid in vids:
    cap = cv.VideoCapture(vid)
    fps = int(cap.get(cv.CAP_PROP_FPS))
    vidlen = int(cap.get(cv.CAP_PROP_FRAME_COUNT))
    fps_list.append(fps)
    vid_lens.append(vidlen)

# Print per line for ease of copying
print(*fps_list, sep="\n")
print(*vid_lens, sep="\n")
