$("form").on("submit", function(event) {
    event.preventDefault();

    console.log("HI THERE!")

    $that = this;

    var oForm = document.getElementById("note_input_form")

    console.log ("FORM::: " + JSON.stringify(oForm))

    var title = document.getElementById("title").value
    var content = document.getElementById("content").innerHTML
    /* var content = oForm.elements["content"].innerHTML */
    var username = document.getElementById("username").innerHTML
    var tag_string = document.getElementById("tag_string").value
    var identifier = document.getElementById("identifier").value

    console.log("content = " + content)
    console.log("title = " + JSON.stringify(title))
    console.log("tag_string = " + tag_string)
    console.log("identifier = " + identifier)

    $.ajax({
        url: "/api/notes/978",
        type: "put",
        data: {
          put: {
            title: title,
            username: username,
            content: content,
            tag_string: tag_string,
            identifier: identifier,
            secret: "abcdef9h5vkfR1Tj0U_1f!"
          }
        },
        headers: {
            "X-CSRF-TOKEN": "csrf"
        },
        dataType: "json",
        success: function (data) {
          console.log(data);
        }
    });

  });