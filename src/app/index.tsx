import { useEffect, useState } from "react";
import { View } from "react-native";
import Account from "./Account";
import Auth from "./Auth";
import { supabase } from "./lib/supabase";

export default function Index() {
  const [userId, setUserId] = useState<string | null>(null);
  const [email, setEmail] = useState<string | undefined>(undefined);

  useEffect(() => {
    // Fetch current user
    const fetchUser = async () => {
      const { data } = await supabase.auth.getUser();
      const user = data?.user ?? null;
      if (user) {
        setUserId(user.id);
        setEmail(user.email ?? undefined);
      }
    };
    fetchUser();

    // Listen for auth state changes
    const { data } = supabase.auth.onAuthStateChange((_event, session) => {
      const user = session?.user ?? null;
      if (user) {
        setUserId(user.id);
        setEmail(user.email ?? undefined);
      } else {
        setUserId(null);
        setEmail(undefined);
      }
    });

    return () => {
      // unsubscribe listener
      data.subscription?.unsubscribe?.();
    };
  }, []);

  return (
    <View>
      {userId ? (
        <Account key={userId} userId={userId} email={email} />
      ) : (
        <Auth />
      )}
    </View>
  );
}
