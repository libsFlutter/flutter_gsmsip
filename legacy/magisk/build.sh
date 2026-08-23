cd gateway
zip -r ../gateway.zip *
cd ..
adb push gateway.zip /storage/self/primary/Download
