Class %Utcov.Test Extends %RegisteredObject
{

ClassMethod listClasses(ns As %String, projectName As %String)
{
    // Switch namespaces to the new one
    new $namespace
    set $namespace = ns

    // Grab our project, by name; fail otherwise
    // TODO: failing is CRUDE at this point...
    #dim project as %Studio.Project
    #dim status as %Status

    // TODO: note sure what the "concurrency" parameter is; leave the default
    // which is -1
    set project = ##class(%Studio.Project).%OpenId(projectName, /* default */, .status)

    if ('status) {
        write "Argh; failed to load", !
        halt // meh... Ugly, f*ing ugly
    }

    w project.Items
}

ClassMethod main()
{
    do ..listClasses("USER", "cache-tort-git")
}

}
