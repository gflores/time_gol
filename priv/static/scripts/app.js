require.config({
    baseUrl: '/static/scripts/lib',
    paths: {
        app: '/static/scripts/app'
    }
});

require(['cs!app/main'])