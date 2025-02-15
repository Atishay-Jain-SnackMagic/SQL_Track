PGDMP                      }         
   exercise_3     17.2 (Ubuntu 17.2-1.pgdg20.04+1)     17.2 (Ubuntu 17.2-1.pgdg20.04+1)     +           0    0    ENCODING    ENCODING        SET client_encoding = 'UTF8';
                           false            ,           0    0 
   STDSTRINGS 
   STDSTRINGS     (   SET standard_conforming_strings = 'on';
                           false            -           0    0 
   SEARCHPATH 
   SEARCHPATH     8   SELECT pg_catalog.set_config('search_path', '', false);
                           false            .           1262    17471 
   exercise_3    DATABASE     p   CREATE DATABASE exercise_3 WITH TEMPLATE = template0 ENCODING = 'UTF8' LOCALE_PROVIDER = libc LOCALE = 'en_IN';
    DROP DATABASE exercise_3;
                     postgres    false            R           1247    24903    usertype    TYPE     C   CREATE TYPE public.usertype AS ENUM (
    'admin',
    'normal'
);
    DROP TYPE public.usertype;
       public               postgres    false            �            1259    24922    articles    TABLE     �   CREATE TABLE public.articles (
    id integer NOT NULL,
    title text NOT NULL,
    category_id integer,
    author_id integer
);
    DROP TABLE public.articles;
       public         heap r       postgres    false            �            1259    24907 
   categories    TABLE     T   CREATE TABLE public.categories (
    id integer NOT NULL,
    name text NOT NULL
);
    DROP TABLE public.categories;
       public         heap r       postgres    false            �            1259    24940    comments    TABLE     y   CREATE TABLE public.comments (
    id integer NOT NULL,
    article_id integer,
    user_id integer,
    comment text
);
    DROP TABLE public.comments;
       public         heap r       postgres    false            �            1259    24939    comments_id_seq    SEQUENCE     �   CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;
 &   DROP SEQUENCE public.comments_id_seq;
       public               postgres    false    221            /           0    0    comments_id_seq    SEQUENCE OWNED BY     C   ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;
          public               postgres    false    220            �            1259    24914    users    TABLE     �   CREATE TABLE public.users (
    id integer NOT NULL,
    name text NOT NULL,
    type public.usertype DEFAULT 'normal'::public.usertype NOT NULL
);
    DROP TABLE public.users;
       public         heap r       postgres    false    850    850            �           2604    24943    comments id    DEFAULT     j   ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);
 :   ALTER TABLE public.comments ALTER COLUMN id DROP DEFAULT;
       public               postgres    false    221    220    221            &          0    24922    articles 
   TABLE DATA           E   COPY public.articles (id, title, category_id, author_id) FROM stdin;
    public               postgres    false    219   g       $          0    24907 
   categories 
   TABLE DATA           .   COPY public.categories (id, name) FROM stdin;
    public               postgres    false    217   5       (          0    24940    comments 
   TABLE DATA           D   COPY public.comments (id, article_id, user_id, comment) FROM stdin;
    public               postgres    false    221   �       %          0    24914    users 
   TABLE DATA           /   COPY public.users (id, name, type) FROM stdin;
    public               postgres    false    218   �       0           0    0    comments_id_seq    SEQUENCE SET     >   SELECT pg_catalog.setval('public.comments_id_seq', 13, true);
          public               postgres    false    220            �           2606    24928    articles articles_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.articles DROP CONSTRAINT articles_pkey;
       public                 postgres    false    219            �           2606    24913    categories categories_pkey 
   CONSTRAINT     X   ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);
 D   ALTER TABLE ONLY public.categories DROP CONSTRAINT categories_pkey;
       public                 postgres    false    217            �           2606    24947    comments comments_pkey 
   CONSTRAINT     T   ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);
 @   ALTER TABLE ONLY public.comments DROP CONSTRAINT comments_pkey;
       public                 postgres    false    221            �           2606    24921    users users_pkey 
   CONSTRAINT     N   ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);
 :   ALTER TABLE ONLY public.users DROP CONSTRAINT users_pkey;
       public                 postgres    false    218            �           2606    24934     articles articles_author_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_author_id_fkey FOREIGN KEY (author_id) REFERENCES public.users(id);
 J   ALTER TABLE ONLY public.articles DROP CONSTRAINT articles_author_id_fkey;
       public               postgres    false    3210    219    218            �           2606    24929 "   articles articles_category_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.articles
    ADD CONSTRAINT articles_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id);
 L   ALTER TABLE ONLY public.articles DROP CONSTRAINT articles_category_id_fkey;
       public               postgres    false    217    219    3208            �           2606    24948 !   comments comments_article_id_fkey    FK CONSTRAINT     �   ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_article_id_fkey FOREIGN KEY (article_id) REFERENCES public.articles(id);
 K   ALTER TABLE ONLY public.comments DROP CONSTRAINT comments_article_id_fkey;
       public               postgres    false    3212    221    219            �           2606    24953    comments comments_user_id_fkey    FK CONSTRAINT     }   ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id);
 H   ALTER TABLE ONLY public.comments DROP CONSTRAINT comments_user_id_fkey;
       public               postgres    false    218    221    3210            &   �   x�=��n�0Dϳ_�_P� W�Z5�"��q��m�kT��V=��i�L��Q�[?�{�2%s�Ѣ����k���/��,|K,R����=�hu��j��fW#z���6��]HJl��G%&W}C[<������g�G$�>Fg�_9���v8��5<��dI�%���թ�u;j��A��>�����B�      $   H   x�3�tM)MN,����2�.�/*)�2�N�L�KN�2�t�+I-*I���M�+�2�IM�PPSp������ ���      (   �   x���=N�0�k��DD�n��@B�E[���:�d�׶l�g;���8	����v����M+Zш72h���Pɝ���#��ϯ+r����Җ�`��*Vr/����	8-�,lG�S-;�e܃q�CMYP"���4�A�E�����3�iS�h��<��0A C)ֲ���N�?df۱XKeu���`�9��9�8���@�חR�n��gs����Kmo?�_���R� ��g�      %   f   x�5�M
� E��}��

��m�v�\TP�OP��g�Ïs��W�U�xr���W��b��Zjf��J��xS���|iG=aJ��÷mE��;���E'6     