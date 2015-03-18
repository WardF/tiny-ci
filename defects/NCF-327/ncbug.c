#include <stdlib.h>
#include <stdio.h>
#include <netcdf.h>

#define FILE_NAME "simple.nc"
#define ERRCODE 2
#define ERR(e) {printf("Error: %s\n", nc_strerror(e)); exit(ERRCODE);}
int
main(void)
{
    int ncid, t_dimid, varid;
    int retval, i;

    /* Create the file. */
    retval = nc_create(FILE_NAME, NC_NETCDF4, &ncid);
    if (retval) ERR(retval);

    /* Define a dimension */
    retval = nc_def_dim(ncid, "t", NC_UNLIMITED, &t_dimid);
    if (retval) ERR(retval);

    /* Define the variable. */
    retval = nc_def_var(ncid, "data", NC_FLOAT, 1, &t_dimid, &varid);
    if (retval) ERR(retval);

    /* Close the file. */
    retval = nc_close(ncid);
    if (retval) ERR(retval);

    for (i = 0; i < 65537; ++i) {
        /* reopen the file */
        retval = nc_open(FILE_NAME,  NC_WRITE, &ncid);
        if (retval) ERR(retval);
	retval = nc_inq_varid(ncid, "data", &varid);
        if (retval) ERR(retval);

	retval = nc_put_att_int(ncid, varid, "recs", NC_INT, 1, &i);
        if (retval) ERR(retval);

	retval = nc_close(ncid);
        if (retval) ERR(retval);
        if (i > 65530) 
           printf("%d\n", i);
        if (i%1000 == 0)
	  printf("*** SUCCESS writing example file %s: %d\n", FILE_NAME, i);
    }
    return 0;
}

