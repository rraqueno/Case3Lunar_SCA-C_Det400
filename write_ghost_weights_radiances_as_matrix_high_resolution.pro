pro write_ghost_weights_radiances_as_matrix_high_resolution, input_image_filename, detector_positions_filename


  input_image_file_basename = file_basename( input_image_filename, '.img')

  envi_open_file, input_image_filename, r_fid=input_fid
  envi_file_query, input_fid, dims=dims, bnames=band_names

  n_bands = n_elements(band_names)

  weight_data = envi_get_data( dims=dims, fid=input_fid, pos=0)

  gt_zero = where( weight_data gt 0.0, n_contributors )

  matrix = dblarr( n_bands, n_contributors )

  matrix[ 0, * ] = weight_data[ gt_zero ]

  header = ["SCA=2; Detector=400;"]

  for i = 1, n_bands - 1 do begin

   header = [header, strmid(band_names[i],48,48) ]

    radiance_data = envi_get_data( dims=dims, fid=input_fid, pos=i)

    matrix[i,*] = radiance_data[ gt_zero ]

  endfor

;
; Write out the data as a CSV file
;
  write_csv, input_image_file_basename+'-Ghost_Weights_Radiances.csv', matrix, header=header 

;
; Write out the data as a text file
;
  openw,  lun,  input_image_file_basename+'-Ghost_Weights_Radiances.txt',/get_lun

printf, lun, matrix

free_lun,lun

;
; Create a matrix that is higher resolution using the L8 positions and 
; bias values.
;
envi_read_cols, detector_positions_filename, l8_data


n_entries = n_elements(l8_data[0,*])

;
; We are adding one additional entry to hold the ghost weights
; in the first column.
; Also adding an unused 0 element in the beginning of band_index
; to match the additional entry of the ghost weights.
;
band_index = [0,reform(l8_data[3,*])]
l8_matrix = dblarr( n_entries+1, n_contributors )

l8_header = ["SCA=2; Detector=400;"]

l8_matrix[0,*] = matrix[0,*]

for j = 1, n_entries do begin

   i = band_index[j]+1
   l8_matrix[ j, * ] = matrix[ i, *] 
   l8_header = [l8_header, strmid(band_names[i],48,48) ]

endfor

;
; Write out the data as a CSV
;
  write_csv, input_image_file_basename+'-high_res_Ghost_Weights_Radiances.csv', l8_matrix, header=l8_header 
 
;
; Write out the data as a text file
;
  openw,  lun,  input_image_file_basename+'-high_res_Ghost_Weights_Radiances.txt',/get_lun

printf, lun, l8_matrix

free_lun,lun

help, l8_matrix

end
