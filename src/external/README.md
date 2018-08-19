## How the sources come

```
png zlib lua luajit websockets curl freetype jpeg tiff webp chipmunk glfw openssl rapidjson bullet box2d
```

### Download Links

```
curl -f -L -- "https://downloads.sourceforge.net/project/libpng/libpng16/older-releases/1.6.16/libpng-1.6.16.tar.xz" > "../../contrib/tarballs/libpng-1.6.16.tar.xz"

curl -f -L -- "http://zlib.net/fossils/zlib-1.2.8.tar.gz" > "../../contrib/tarballs/zlib-1.2.8.tar.gz"

curl -f -L -- "http://www.lua.org/ftp/lua-5.1.4.tar.gz" > "../../contrib/tarballs/lua-5.1.4.tar.gz"

curl -f -L -- "http://luajit.org/download/LuaJIT-2.1.0-beta2.tar.gz" > "../../contrib/tarballs/LuaJIT-2.1.0-beta2.tar.gz"

rm -Rf ../../contrib/tarballs/libwebsockets-git && git clone --branch master https://github.com/warmcat/libwebsockets ../../contrib/tarballs/libwebsockets-git && (cd ../../contrib/tarballs/libwebsockets-git && git checkout  7355750) && rm -Rf ../../contrib/tarballs/libwebsockets-git/.git && (cd ../../contrib/tarballs/ && tar cvJ libwebsockets-git) > ../../contrib/tarballs/libwebsockets-git.tar.xz && rm -Rf ../../contrib/tarballs/libwebsockets-git

curl -f -L -- "https://www.openssl.org/source/openssl-1.1.0c.tar.gz" > "../../contrib/tarballs/openssl-1.1.0c.tar.gz"

curl -f -L -- "http://curl.haxx.se/download/curl-7.52.1.tar.gz" > "../../contrib/tarballs/curl-7.52.1.tar.gz"

curl -f -L -- "https://downloads.sourceforge.net/project/freetype/freetype2/2.5.5/freetype-2.5.5.tar.gz" > "../../contrib/tarballs/freetype-2.5.5.tar.gz"

curl -f -L -- "http://www.ijg.org/files/jpegsrc.v9b.tar.gz" > "../../contrib/tarballs/jpegsrc.v9b.tar.gz"

curl -f -L -- "http://download.osgeo.org/libtiff/old/tiff-4.0.3.tar.gz" > "../../contrib/tarballs/tiff-4.0.3.tar.gz"

curl -f -L -- "http://downloads.webmproject.org/releases/webp/libwebp-0.5.0.tar.gz" > "../../contrib/tarballs/libwebp-0.5.0.tar.gz"

curl -f -L -- "https://chipmunk-physics.net/release/Chipmunk-7.x/Chipmunk-7.0.1.tgz" > "../../contrib/tarballs/Chipmunk-7.0.1.tgz"

curl -f -L -- "https://codeload.github.com/glfw/glfw/tar.gz/3.2.1" > "../../contrib/tarballs/glfw-3.2.1.tar.gz"

rm -Rf ../../contrib/tarballs/librapidjson-git && git clone --branch master https://github.com/miloyip/rapidjson ../../contrib/tarballs/librapidjson-git && (cd ../../contrib/tarballs/librapidjson-git && git checkout  3d5848a) && rm -Rf ../../contrib/tarballs/librapidjson-git/.git && (cd ../../contrib/tarballs/ && tar cvJ librapidjson-git) > ../../contrib/tarballs/librapidjson-git.tar.xz && rm -Rf ../../contrib/tarballs/librapidjson-git

rm -Rf ../../contrib/tarballs/libbullet-git && git clone --branch master https://github.com/bulletphysics/bullet3 ../../contrib/tarballs/libbullet-git && (cd ../../contrib/tarballs/libbullet-git && git checkout  19f999a) && rm -Rf ../../contrib/tarballs/libbullet-git/.git && (cd ../../contrib/tarballs/ && tar cvJ libbullet-git) > ../../contrib/tarballs/libbullet-git.tar.xz && rm -Rf ../../contrib/tarballs/libbullet-git

rm -Rf ../../contrib/tarballs/libbox2d-git && git clone --branch master https://github.com/erincatto/Box2D ../../contrib/tarballs/libbox2d-git && (cd ../../contrib/tarballs/libbox2d-git && git checkout  f655c603ba9d83f07fc566d38d2654ba35739102) && rm -Rf ../../contrib/tarballs/libbox2d-git/.git && (cd ../../contrib/tarballs/ && tar cvJ libbox2d-git) > ../../contrib/tarballs/libbox2d-git.tar.xz && rm -Rf ../../contrib/tarballs/libbox2d-git

```