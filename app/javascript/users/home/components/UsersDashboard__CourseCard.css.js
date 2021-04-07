module.exports = {
  courseCard: (theme) => {
    return {
      '.course-card': {
        width: theme('width.full'),
        marginTop: theme('margin.6'),
        paddingLeft: theme('padding.3'),
        paddingRight: theme('padding.3'),

        '@screen md': {
          width: theme('width.1/2'),
          marginTop: theme('margin.10'),
        },

        '@screen lg': {
          paddingLeft: theme('padding.5'),
          paddingRight: theme('padding.5'),
        },
      }
    }
  }
};
