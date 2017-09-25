# FOURJS_START_COPYRIGHT(P,2017)
# Property of Four Js*
# (c) Copyright Four Js 2017, 2017. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# FOURJS_END_COPYRIGHT

{
clean( id SMALLINT )
Removes all pictures from an fglgallery.

deleteImages(
   id SMALLINT,
   indexes DYNAMIC ARRAY OF INTEGER )
  RETURNS STRING
Deletes pictures used in an fglgallery.

flush( id SMALLINT )
Displays new added images to the end user.

getImageCount( id SMALLINT )
  RETURNS INTEGER
Returns the number of pictures in an fglgallery.

getPath(
   id SMALLINT,
   index STRING )
  RETURNS STRING
Returns the URL of a picture in an fglgallery.

getTitle(
   id SMALLINT,
   index STRING )
  RETURNS STRING
Returns the description of a picture in an fglgallery.
}

IMPORT util
IMPORT FGL fglgallery

DEFINE rec RECORD
               gallery_type INTEGER,
               gallery_size INTEGER,
               current_idx INTEGER,
               current_title STRING,
               current_url STRING,
               gallery_wc STRING
           END RECORD

# The t_struct_value type holds image selection data.    
DEFINE struct_value fglgallery.t_struct_value

# Flow of the sample +
# Create the object +
# Add Initial Images +
# Display fglgallery +
# Show current selected image (form field) +
# Show how many images are selected out of the total available in the current gallery (Message) +
# Show Path/URI for selected image (form field) +
# Delete multiple images + refresh gallery
# Clean it
# Re-incorporate new images

MAIN
    DEFINE id SMALLINT
    DEFINE cleaned BOOLEAN
    DEFINE srcfile, dstfile, fename STRING
    DEFINE tok base.StringTokenizer 

    LET fename = ui.interface.getFrontEndName()

    OPEN FORM f1 FROM "wc_fglgallery"
    DISPLAY FORM f1

    OPTIONS INPUT WRAP, FIELD ORDER FORM

    # Preparing the fglgallery library for use
    CALL fglgallery.initialize()

    # Creating a new fglgallery handle.
    LET id = fglgallery.create("formonly.gallery_wc")

    # Enabling multiple picture selection in an fglgallery
    CALL fglgallery.setMultipleSelection( id, TRUE )

    # Adding picture resources to a fglgallery object
    
    -- Image files on the server, to be handled with filenameToURI()/FGLIMAGEPATH
    -- From images-public dir:
    CALL fglgallery.addImage(id, image_path("image01.jpg"), "Lake in mountains")
    CALL fglgallery.addImage(id, image_path("image02.jpg"), NULL)
    CALL fglgallery.addImage(id, image_path("image03.jpg"), "Lightning")
    -- From images-private dir:
    CALL fglgallery.addImage(id, image_path("image10.jpg"), "Outdoor cat")
    CALL fglgallery.addImage(id, image_path("image11.jpg"), NULL)
    -- URLs
    CALL fglgallery.addImage(id, "http://freebigpictures.com/wp-content/uploads/2009/09/mountain-ridge.jpg", "Mountain ridge")
    CALL fglgallery.addImage(id, "http://freebigpictures.com/wp-content/uploads/2009/09/mountain-horse.jpg", "Horse in field")
    CALL fglgallery.addImage(id, "http://freebigpictures.com/wp-content/uploads/forest-in-spring-646x433.jpg", "Forest in spring")
    CALL fglgallery.addImage(id, "http://freebigpictures.com/wp-content/uploads/2009/09/mountain-waterfall.jpg", "Montain waterfall" )
    CALL fglgallery.addImage(id, "http://freebigpictures.com/wp-content/uploads/2009/09/summer-river-646x432.jpg", "River in summer")
    CALL fglgallery.addImage(id, "http://freebigpictures.com/wp-content/uploads/2009/09/reservoir-lake.jpg", "Reservoir lake")

    LET rec.gallery_type = FGLGALLERY_TYPE_THUMBNAILS
    LET rec.gallery_size = FGLGALLERY_SIZE_NORMAL
    LET struct_value.current = 1
    LET rec.gallery_wc = util.JSON.stringify(struct_value)
    LET cleaned = FALSE
    CALL fglgallery.display(id, rec.gallery_type, rec.gallery_size)

    INPUT BY NAME rec.* ATTRIBUTES (UNBUFFERED, WITHOUT DEFAULTS)

    ON CHANGE gallery_type
        # Displays current fglgallery object to the end user
        CALL fglgallery.display(id, rec.gallery_type, rec.gallery_size)

    ON CHANGE gallery_size
         # Displays current fglgallery object to the end user
        CALL fglgallery.display(id, rec.gallery_type, rec.gallery_size)

    ON ACTION set_current ATTRIBUTES(TEXT="Set current")
          LET struct_value.current = 6
          LET rec.gallery_wc = util.JSON.stringify(struct_value)

    ON ACTION image_selection ATTRIBUTES(DEFAULTVIEW=NO)
        CALL util.JSON.parse( rec.gallery_wc, struct_value )
        LET rec.current_idx = struct_value.current
        LET rec.current_title = fglgallery.getTitle(id, rec.current_idx)
        LET rec.current_url = fglgallery.getPath(id, rec.current_idx)
        MESSAGE "You selected " || struct_value.selected.getLength() || " images out of " || fglgallery.getImageCount(id) || " possible"

    ON ACTION delete
       IF (mbox_ync("Delete Warning", "Are you sure you want to delete the current image selection ?")) THEN
         CALL fglgallery.deleteImages(id, struct_value.selected)
         CALL mbox_ok("Delete Confirmation" , struct_value.selected.getLength() || " images deleted")
       END IF

    ON ACTION clean
        CALL fglgallery.clean(id)
        MESSAGE ""
        LET cleaned = TRUE
        
    ON ACTION add_logo
         CALL fglgallery.addImage(id, "https://4js.com/wp-content/uploads/2015/05/logo_4Js_2014_CMYK_seul-300x92.png", "Four Js Logo")
         IF cleaned THEN
           CALL fglgallery.display(id, rec.gallery_type, rec.gallery_size)
         ELSE
           CALL fglgallery.flush(id)
         END IF
         
    ON ACTION add_local_img
      CASE
        WHEN (fename = "GDC" OR fename = "GBC")
          CALL ui.Interface.frontCall("standard", "openFile",["$HOME/Desktop","newimage.jpg","*.png *.jpg","Choose a file to upload"],[srcfile])

          # Maybe you should add some logic file client machine delimiter (Windows vs MacOs)
          LET tok = base.StringTokenizer.create(srcfile,"/")
            WHILE tok.hasMoreTokens()
              LET dstfile = tok.nextToken()
            END WHILE

           TRY
             CALL fgl_getfile(srcfile, base.Application.getProgramDir() || "images-private/" || dstfile )
             MESSAGE "File uploaded"
           CATCH
             ERROR sqlca.sqlcode
           END TRY
      
         WHEN (fename = "GMA" OR fename = "GMI")
          CALL ui.Interface.frontCall("mobile", "choosePhoto", [], [srcfile])
          LET dstfile = util.Math.rand(1000) || ".jpg"
          
          TRY
            CALL fgl_getfile(srcfile,base.Application.getProgramDir() || "images-private/" || dstfile)
            MESSAGE "File uploaded"
          CATCH
             ERROR sqlca.sqlcode
           END TRY
          
        OTHERWISE
          ERROR "Invalid Front-End"
      END CASE

      CALL fglgallery.addImage(id, image_path(dstfile), "Vacation gateway")
      IF cleaned THEN
           CALL fglgallery.display(id, rec.gallery_type, rec.gallery_size)
      ELSE
           CALL fglgallery.flush(id)
      END IF
      
    ON ACTION close
        EXIT INPUT

    END INPUT

    # Frees resources allocated for an fglgallery
    CALL fglgallery.destroy(id)

    # Releasing the fglgallery library
    CALL fglgallery.finalize()

END MAIN

FUNCTION image_path(path)
    DEFINE path STRING
    RETURN ui.Interface.filenameToURI(path)
END FUNCTION

FUNCTION display_type_init(cb)
    DEFINE cb ui.ComboBox
    CALL cb.addItem(FGLGALLERY_TYPE_MOSAIC,        "Mosaic")
    CALL cb.addItem(FGLGALLERY_TYPE_LIST,          "List")
    CALL cb.addItem(FGLGALLERY_TYPE_THUMBNAILS,    "Thumbnails")
END FUNCTION

FUNCTION display_size_init(cb)
    DEFINE cb ui.ComboBox
    CALL cb.addItem(FGLGALLERY_SIZE_XSMALL, "X-Small")
    CALL cb.addItem(FGLGALLERY_SIZE_SMALL,  "Small")
    CALL cb.addItem(FGLGALLERY_SIZE_NORMAL, "Normal")
    CALL cb.addItem(FGLGALLERY_SIZE_LARGE,  "Large")
    CALL cb.addItem(FGLGALLERY_SIZE_XLARGE, "X-Large")
END FUNCTION

FUNCTION mbox_ync(title,msg)
    DEFINE title, msg STRING
    DEFINE res SMALLINT
    MENU title ATTRIBUTES(STYLE="dialog",COMMENT=msg)
        ON ACTION yes     LET res = 1
        ON ACTION no      LET res = 0
        ON ACTION cancel  LET res = -1
    END MENU
    RETURN res
END FUNCTION

FUNCTION mbox_ok(title,msg)
    DEFINE title, msg STRING
    MENU title ATTRIBUTES(STYLE="dialog",COMMENT=msg)
        ON ACTION accept
    END MENU
END FUNCTION
