type supabaseClient = {auth: SupabaseAuth.auth, storage: SupabaseStorage.storage}

@module("@supabase/supabase-js")
external createClient: (string, string) => supabaseClient = "createClient"

@scope(("process", "env")) @val
external supabaseUrl: string = "REACT_APP_SUPABASE_URL"

@scope(("process", "env")) @val
external supabaseAnonKey: string = "REACT_APP_SUPABASE_ANON_KEY"

let supabase = createClient(supabaseUrl, supabaseAnonKey)
