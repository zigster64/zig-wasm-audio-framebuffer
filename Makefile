build:
	zig build

clean:
	rm -rf zig-cache zig-out

run:
	cd zig-out && python3 -m http.server 8000
