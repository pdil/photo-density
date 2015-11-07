package com.company;

import com.drew.metadata.*;
import com.drew.imaging.*;
import com.drew.lang.GeoLocation;
import com.drew.metadata.exif.ExifSubIFDDirectory;
import com.drew.metadata.exif.GpsDirectory;

import java.io.*;
import java.util.Calendar;
import java.util.Locale;

public class Main {

    // gets extension name from argument file path, returns empty string if blank
    private static String getExtension(String filePath) {
        int i = filePath.lastIndexOf('.');

        if (i > 0) {
            return filePath.substring(i + 1);
        }

        return "";
    }

    public static void main(String[] args) throws IOException, ImageProcessingException {
        File dir = new File("/Users/paolo/Desktop/GeoDensityMap/Pictures");
        File[] listFiles = dir.listFiles();
        Metadata md;

        int id = 1;
        double lat, lon;

        System.out.println("Opening file stream...");

        Writer w = null;

        try {
            w = new BufferedWriter(
                    new OutputStreamWriter(
                            new FileOutputStream("/Users/paolo/Desktop/GeoDensityMap/geoDataTable.csv"), "utf-8"
                    )
            );

            w.write("id, year, month, day, file, lat, lon\n");
        } catch (IOException ex) {
            System.out.println("Error printing to file (id=header)");
        }

        System.out.println("Table header written");
        System.out.println("Extracting data...");

        for (int i = 0; i < listFiles.length; i++) {
            // only accept image files
            if (getExtension(listFiles[i].getPath()).equalsIgnoreCase("jpg") ||
                    getExtension(listFiles[i].getPath()).equalsIgnoreCase("jpeg")) {

                md = ImageMetadataReader.readMetadata(listFiles[i]);

                // get geolocation date
                GpsDirectory gpsD = md.getDirectory(GpsDirectory.class);
                if (gpsD == null) {
                    // input "null" values for missing geo data
                    lat = -999;
                    lon = -999;
                } else {
                    GeoLocation geoL = gpsD.getGeoLocation();
                    lat = geoL.getLatitude();
                    lon = geoL.getLongitude();
                }

                Calendar cal = Calendar.getInstance();
                int year, day;
                String month;

                try {
                    // convert Date object to Calendar
                    cal.setTime(md.getDirectory(ExifSubIFDDirectory.class).getDate(ExifSubIFDDirectory.TAG_DATETIME_ORIGINAL));
                    year = cal.get(Calendar.YEAR);
                    month = cal.getDisplayName(Calendar.MONTH, Calendar.SHORT, Locale.getDefault());
                    day = cal.get(Calendar.DAY_OF_MONTH);
                } catch (NullPointerException e) {
                    // input "null" value for missing date
                    year = -999;
                    month = Integer.toString(-999);
                    day = -999;
                }

                // System.out.println(id + "," + date + "," + listFiles[i].getName() + "," + lat + "," + lon);

                try {
                    w.write(id + "," + year + "," + month + "," + day + ","
                            + listFiles[i].getName() + "," + lat + "," + lon + "\n");
                } catch (IOException ex) {
                    System.out.println("Error printing to file (id=" + id);
                }

                id++;
            }

        }

        try {
            w.close();
        } catch (Exception e) { }

        System.out.println("Output table complete, n = " + (id - 1));
    }
}
