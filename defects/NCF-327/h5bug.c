#include <stdio.h>
#include <stdlib.h>
#include <hdf5.h>

#define FILE_NAME            "simple.h5"
#define DATASET         "data"
#define DRANK           1
#define ATTRIBUTE       "recs"

int
main (void)
{
    hid_t       file, vspace, aspace, dset, attr;   /* Handles */
    hid_t       plist;
    hid_t       vtype;
    herr_t      retval;
    hsize_t     dims[DRANK];
    hsize_t     maxdims[DRANK];
    hsize_t     chunklens[DRANK];
    int         wdata[2], ndims, i;
    int         attval = 1;

    /* Create the file. */
    file = H5Fcreate (FILE_NAME, H5F_ACC_TRUNC, H5P_DEFAULT, H5P_DEFAULT);

    /* Define a dataspace */
    dims[0] = 1;
    maxdims[0] = H5S_UNLIMITED;
    vspace = H5Screate_simple(DRANK, dims, maxdims);

    /* Define the dataset (variable). */
    vtype = H5Tcopy(H5T_NATIVE_INT);
    retval = H5Tset_order(vtype, H5T_ORDER_LE);
    /* Need to set layout to chunked, using property list */
    plist = H5Pcreate(H5P_DATASET_CREATE);
    chunklens[0] = 1048576;
    retval = H5Pset_chunk(plist, DRANK, chunklens);
    dset = H5Dcreate (file, DATASET, vtype, vspace, H5P_DEFAULT, plist, H5P_DEFAULT);
    /* Write a little data */
    retval = H5Dwrite(dset, H5T_NATIVE_INT, H5S_ALL, H5S_ALL, H5P_DEFAULT, wdata);

    /*
     * Create dataspace for attribute.
     */
    aspace = H5Screate (H5S_SCALAR);

    /*
     * Create the attribute and write the integer data to it.
     */
    attr = H5Acreate (dset, ATTRIBUTE, H5T_STD_I64BE, aspace, H5P_DEFAULT,
                H5P_DEFAULT);
    retval = H5Awrite (attr, H5T_NATIVE_INT, &attval);

    /*
     * Close and release resources.
     */
    retval = H5Aclose (attr);
    retval = H5Dclose (dset);
    retval = H5Sclose (vspace);
    retval = H5Sclose (aspace);
    retval = H5Fclose (file);

    for (i = 0; i < 65537; ++i) {
        /* reopen the file, dataset, and attribute */
	file = H5Fopen (FILE_NAME, H5F_ACC_RDWR, H5P_DEFAULT);
	dset = H5Dopen (file, DATASET, H5P_DEFAULT);
	attr = H5Aopen (dset, ATTRIBUTE, H5P_DEFAULT);
	/* update attribute value */
	retval = H5Awrite(attr, H5T_NATIVE_INT, &i);
	retval = H5Aclose (attr);
	retval = H5Dclose (dset);
	retval = H5Fclose (file);
        if (i > 65530) 
           printf("%d\n", i);
        if (i%1000 == 0)
	  printf("*** SUCCESS writing example file %s: %d\n", FILE_NAME, i);
    }
    return 0;
}
