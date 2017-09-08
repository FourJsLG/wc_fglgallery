# FOURJS_START_COPYRIGHT(P,2017)
# Property of Four Js*
# (c) Copyright Four Js 2017, 2017. All Rights Reserved.
# * Trademark of Four Js Development Tools Europe Ltd
#   in the United States and elsewhere
# FOURJS_END_COPYRIGHT

IMPORT util
IMPORT FGL fglgallery

DEFINE rec RECORD
               gallery_type INTEGER,
               gallery_size INTEGER,
               current INTEGER,
               gallery_wc STRING
           END RECORD
DEFINE struct_value fglgallery.t_struct_value

MAIN
    DEFINE id SMALLINT

    OPEN FORM f1 FROM "wc_fglgallery"
    DISPLAY FORM f1

    OPTIONS INPUT WRAP, FIELD ORDER FORM

    CALL fglgallery.initialize()
    LET id = fglgallery.create("formonly.gallery_wc")

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

    LET rec.gallery_type = FGLGALLERY_TYPE_MOSAIC
    LET rec.gallery_size = FGLGALLERY_SIZE_NORMAL
    LET struct_value.current = 1
    LET rec.current = struct_value.current
    LET rec.gallery_wc = util.JSON.stringify(struct_value)
    CALL fglgallery.display(id, rec.gallery_type, rec.gallery_size)

    INPUT BY NAME rec.* ATTRIBUTES (UNBUFFERED, WITHOUT DEFAULTS)

    ON CHANGE gallery_type
        CALL fglgallery.display(id, rec.gallery_type, rec.gallery_size)

    ON CHANGE gallery_size
        CALL fglgallery.display(id, rec.gallery_type, rec.gallery_size)

    ON ACTION set_current ATTRIBUTES(TEXT="Set current")
        LET struct_value.current = rec.current
        LET rec.gallery_wc = util.JSON.stringify(struct_value)

    ON ACTION image_selection ATTRIBUTES(DEFAULTVIEW=NO)
        CALL util.JSON.parse( rec.gallery_wc, struct_value )
        LET rec.current = struct_value.current

    ON ACTION close
        EXIT INPUT

    END INPUT

    CALL fglgallery.destroy(id)
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
