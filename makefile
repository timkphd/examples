examples.zip:
	zip -r examples.zip . -x '*.git*'  -x '*MACOSX*' -x '.DS_Store'
	tree -H . > index.html
	ls -lt examples.zip

clean:
	rm -rf *zip
	tree -H . > index.html

