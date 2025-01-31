# Templates

put your _VS Script_ & _Encode Param_ templates here

- for _VS Script_ template, use `.py` extension
- for _Encode Param_ template, use `.txt` extension

#### Note:

for _VS Script_ template, you should use `os.getenv("FINALRIP_SOURCE")` to get the real source file path in the FinalRip container

```python
if os.getenv("FINALRIP_SOURCE"):
    clip = core.bs.VideoSource(source=os.getenv("FINALRIP_SOURCE"))
    # clip = core.bs.VideoSource(source="FINALRIP_SOURCE.mkv")
else:
    clip = core.bs.VideoSource(source="s.mkv")
```

for _Encode Param_ template, you should use `-i -` to read from stdin, and specify the output file path `FINALRIP_ENCODED_CLIP.mkv`

```bash
ffmpeg -i - -pix_fmt yuv420p10le -c:v libx265 -crf 16 FINALRIP_ENCODED_CLIP.mkv
```

FinalRip will auto complete the command (encode.py is the _VS Script_ template file):

```bash
vspipe -c y4m encode.py - | ffmpeg -i - -pix_fmt yuv420p10le -c:v libx265 -crf 16 FINALRIP_ENCODED_CLIP.mkv
```
