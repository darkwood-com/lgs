Generate all xcode 5 app icon sizes from one original large icon
----------------------------------------------------------------

https://github.com/danielpovlsen/ios-icons-launch-images-generator

Icon
----

```
  mkdir -p generated
  
  sips -Z 29 --out generated/iPhoneSettings-29x29.png sourceIcon.png
  sips -Z 58 --out generated/iPhoneSettings-29x29@2x.png sourceIcon.png
  sips -Z 87 --out generated/iPhoneSettings-29x29@3x.png sourceIcon.png
  sips -Z 80 --out generated/iPhoneSpotlight-40x40@2x.png sourceIcon.png
  sips -Z 120 --out generated/iPhoneSpotlight-40x40@3x.png sourceIcon.png
  sips -Z 120 --out generated/iPhoneApp-60x60@2x.png sourceIcon.png
  sips -Z 180 --out generated/iPhoneApp-60x60@3x.png sourceIcon.png
  
  sips -Z 29 --out generated/iPadSettings-29x29.png sourceIcon.png
  sips -Z 58 --out generated/iPadSettings-29x29@2x.png sourceIcon.png
  sips -Z 40 --out generated/iPadSpotlight-40x40.png sourceIcon.png
  sips -Z 80 --out generated/iPadSpotlight-40x40@2x.png sourceIcon.png
  sips -Z 76 --out generated/iPadApp-76x76.png sourceIcon.png
  sips -Z 152 --out generated/iPadApp-76x76@2x.png sourceIcon.png
```

Launch Images
-------------

```
  sips -Z 960 -c 640 960 -r 90 sourceLaunch --out generated/Default640x960.png
  sips -Z 480 generated/Default640x960.png --out generated/Default320x480.png
  sips -Z 1136 -c 640 1136 -r 90 sourceLaunch --out generated/Default640x1136.png
  
  sips -Z 2208 -c 1242 2208 sourceLaunch --out generated/Default2208x1242.png
  sips -r 90 generated/Default2208x1242.png --out generated/Default1242x2208.png
  sips -Z 1334 -c 750 1334 -r 90 sourceLaunch --out generated/Default750x1334.png
  
  sips -Z 2048 sourceLaunch --out generated/Default2048x1536.png
  sips -r 90 generated/Default2048x1536.png --out generated/Default1536x2048.png
  sips -Z 1024 generated/Default2048x1536.png --out generated/Default1024x768.png
  sips -r 90 generated/Default1024x768.png --out generated/Default768x1024.png
```
