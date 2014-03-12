`import styleSupport from 'appkit/mixins/style-support'`
`import sizeSupport from 'appkit/mixins/size-support'`
`import popupComponent from 'appkit/components/eui-popup'`
`import disabledSupport from 'appkit/mixins/disabled-support'`
`import widthSupport from 'appkit/mixins/width-support'`
`import validationSupport from 'appkit/mixins/validation-support'`

select = Em.Component.extend styleSupport, sizeSupport, disabledSupport, widthSupport, validationSupport,
  tagName: 'div'
  classNames: ['eui-select']
  classNameBindings: ['isDisabled:eui-disabled', 'selection::eui-placeholder', 'popupIsOpen:eui-active', 'class']

  popupIsOpen: false
  required: false
  options: []
  labelPath: 'label'
  valuePath: 'value'

  optionsWithBlank: Em.computed ->
    options = @get('options')
    paddedOptions = options[..]

    unless @get('required')
      paddedOptions.unshift(null)

    return paddedOptions
  .property 'options.@each required'

  label: Em.computed ->
    labelPath = @get('labelPath')
    return @get("selection.#{labelPath}") || @get('placeholder')
  .property('selection', 'placeholder', 'labelPath')

  value: Ember.computed (key, value) ->
    # setter
    if arguments.length is 2
      valuePath = @get('valuePath')
      selection = value
      selection = @get('options').findProperty(valuePath, value) if valuePath
      @set('selection', selection)
      value

    # getter
    else
      valuePath = @get('valuePath')
      if valuePath then @get("selection.#{valuePath}") else null
  .property 'selection'

  initialization: (->
    # Create observer for the selection's label so we can monitor it for changes
    labelPath = 'selection.' + @get('labelPath')
    @addObserver(labelPath, -> @notifyPropertyChange 'label')

    # Set the initial selection based on the value of the select
    return if @get('selection')
    valuePath = @get('valuePath')
    value = @get('value')
    value = @get('options').findProperty(valuePath, value) if valuePath
    @set('selection', value || null)
  ).on('init')

  click: ->
    unless @get('popupIsOpen')
      popupComponent.show
        targetObject: @
        isOpenBinding: 'targetObject.popupIsOpen'
        selectionBinding: 'targetObject.selection'
        options: @get('optionsWithBlank')
        style: 'flyin'
        labelPath: @get('labelPath')
        event: 'select'

  # Overide validation-support mixin to check validation on change even if no error
  onChange:  (->
    Ember.run.once(@, 'validateField')
  ).observes 'value'

`export default select`
