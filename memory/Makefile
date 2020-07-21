SUBDIRS = linux malloc_count-0.7.1/test-malloc_count  malloc_count-0.7.1/test-memprofile

# This is how we would add another directory to our list
# however this directory will only compile on a bgq so
# we have it commented out.
# SUBDIRS += bgq

.PHONY: compilers

include compilers

# Interesting trick...
# This expands to each item in SUBDIRS with clean- prepended
CLEANDIRS = $(SUBDIRS:%=clean-%)

.PHONY: subdirs $(SUBDIRS)

subdirs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@


.PHONY: clean

clean: $(CLEANDIRS)

$(CLEANDIRS): 
# From above, CLEANDIRS is each item in SUBDIRS with clean- prepended 
	echo $(@)
# Cut off "clean-" and go there and do a make clean
	echo $(@:clean-%=%)
	$(MAKE) -C $(@:clean-%=%) clean

.PHONY: printvars
printvars:
	make -f Makefile -f make.printvars printvars

#For more examples see 
#https://lackof.org/taggart/hacking/make-example/
#http://mrbook.org/blog/tutorials/make/
#https://www.gnu.org/software/make/manual/make.html
#https://www.cmcrossroads.com/article/dumping-every-makefile-variable 

