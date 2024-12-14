# Templates

put your _vs script_ & _ffmpeg param_ templates here

- for _vs script_ template, use `.py` extension
- for _ffmpeg param_ template, use `.txt` extension

#### Note:

for _vs script_ template, you should use `os.getenv("FINALRIP_SOURCE")` to get the real source file path in the FinalRip container

```python
if os.getenv("FINALRIP_SOURCE"):
    clip = core.bs.VideoSource(source=os.getenv("FINALRIP_SOURCE"))
else:
    clip = core.bs.VideoSource(source="s.mkv")
```

for _ffmpeg param_ template, you should use `-i -` to read from stdin and don't add any output file path

```txt
ffmpeg -i - -vcodec libx265 -crf 16
```

FinalRip will auto complete the command:

```txt
vspipe -c y4m encode.py - | ffmpeg -i - -vcodec libx265 -crf 16 encoded.mkv
```

- encode.py is the _vs script_ template file and encoded.mkv is the output file path
