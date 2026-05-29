from nifiapi.properties import PropertyDescriptor
from nifiapi.properties import StandardValidators
from nifiapi.flowfiletransform import FlowFileTransform
from nifiapi.flowfiletransform import FlowFileTransformResult

class ConvertCSVToParquet(FlowFileTransform):
    class Java:
        implements = ["org.apache.nifi.python.processor.FlowFileTransform"]

    class ProcessorDetails:
        version = "0.0.1-Python"
        description = """
        Este processor é responsável por ler um arquivo no formato
        CSV e converter em parquet. Necessário passar o
         encoding desejado.
        """
        tags = ["csv", "parquet", "python", "convert"]

    DECODIFICACAO = PropertyDescriptor(
        name = "Decodificação",
        description = "Escolha a decodificação do arquivo",
        default_value = "UTF-8",
        validators = [StandardValidators.NON_EMPTY_VALIDATOR],
        required = True
    )

    property_descriptors = [
        DECODIFICACAO
    ]

    def __init__(self, **kwargs):
        pass

    def getPropertyDescriptors(self):
        return self.property_descriptors

    def getDynamicPropertyDescriptor(self, propertyname):
        return PropertyDescriptor(
            name = propertyname,
            description = "Uma propriedade definida pelo usuário",
            validators = [StandardValidators.NON_EMPTY_VALIDATOR],
            dynamic = True
        )

    def transform(self, context, flowfile):
        
        from io import StringIO, BytesIO
        import pandas as pd

        try:

            nome_arquivo = (
                flowfile
                .getAttribute("filename")
            )

            decodificador = (
                context
                .getProperty(self.DECODIFICACAO)
                .evaluateAttributeExpressions(flowfile)
                .getValue()
            )

            conteudo = (
                flowfile
                .getContentsAsBytes()
                .decode(F"{decodificador}")
            )

            df = pd.read_csv(StringIO(conteudo))
            
            parquet_buffer = BytesIO()

            df.to_parquet(parquet_buffer, engine='pyarrow', index=False)

            parquet_buffer.seek(0)  # Reinicia o ponteiro para o início do buffer

            finalParquetFile = parquet_buffer.getvalue()

            atributos = (
                {
                    "mime.type": "application/x-parquet",
                    "filename": f"{nome_arquivo.split('.')[0]}.parquet"
                }
            )

            return FlowFileTransformResult(
                relationship = "success",
                contents = finalParquetFile,
                attributes = atributos
            )

        except Exception as erro:
            nome_arquivo = (
                flowfile
                .getAttribute("filename")
            )

            atributos = (
                {
                    "mime.type": "application/x-parquet",
                    "filename": nome_arquivo.strip(),
                    "error": f"{erro}"
                }
            )

            return FlowFileTransformResult(
                relationship = "failure",
                attributes = atributos
            )