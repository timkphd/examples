# just does a cleanup after a run to get things back to "repo" state
SUBDIRS=affinity array gpu slurm0 slurm1  

.PHONY: subdirs $(SUBDIRS)

subdirs: $(SUBDIRS)

$(SUBDIRS):
	$(MAKE) -C $@ clean

affinity:slurm1

