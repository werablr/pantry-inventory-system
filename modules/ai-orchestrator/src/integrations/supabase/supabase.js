// lib/supabase.js
import { createClient } from '@supabase/supabase-js';

const SUPABASE_URL = process.env.EXPO_PUBLIC_SUPABASE_URL || 'https://hazopdgqiezcbwmmevqn.supabase.co';
const SUPABASE_ANON_KEY = process.env.EXPO_PUBLIC_SUPABASE_ANON_KEY || 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imhhem9wZGdxaWV6Y2J3bW1ldnFuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDkyMzkwOTYsImV4cCI6MjA2NDgxNTA5Nn0.PKtMSX0Wv2VOk_03sfe76w1a8lhJrRVDYAyrWIZ7Stk';

export const supabase = createClient(SUPABASE_URL, SUPABASE_ANON_KEY);