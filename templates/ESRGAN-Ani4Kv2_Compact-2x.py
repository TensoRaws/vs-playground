import os
import vapoursynth as vs
from vapoursynth import core
from vsrealesrgan import realesrgan, RealESRGANModel

if os.getenv('FINALRIP_SOURCE'):
    clip = core.bs.VideoSource(source=os.getenv('FINALRIP_SOURCE'))
else:
    clip = core.bs.VideoSource(source="s.mkv")

clip = core.resize.Bicubic(clip=clip, format=vs.RGBH, matrix_in_s='709')
clip = realesrgan(clip=clip, model=RealESRGANModel.Ani4Kv2_Compact_2x)
clip = core.resize.Bicubic(clip=clip, matrix_s="709", format=vs.YUV420P16)
clip.set_output()
