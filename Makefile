.PHONY: all shell run clean

all:
	erl -make

shell:
	erl -pa ebin

run:
	erl -pa ebin -s sq

clean:
	rm ebin/*.beam
